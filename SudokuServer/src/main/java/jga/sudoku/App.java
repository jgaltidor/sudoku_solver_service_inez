package jga.sudoku;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import fi.iki.elonen.NanoHTTPD;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

public class App extends NanoHTTPD
{
  private static class Config
  {
    private final File solverScript;
    private final File sudokuConfigFile;
    private final File sudokuOutputFile;
    private final int port;

    Config(File runSolverScript, File sudokuConfigFile, File sudokuOutputFile, int port)
    {
      this.solverScript = runSolverScript;
      this.sudokuConfigFile = sudokuConfigFile;
      this.sudokuOutputFile = sudokuOutputFile;
      this.port = port;
    }
  }

  private static final String configFileName = "sudoku_server.conf";

  private static Config loadConfig() throws IOException {
    Properties props = new Properties();
    props.load(App.class.getClassLoader().getResourceAsStream(configFileName));
    File solverScript = new File(props.getProperty("solver_script_file"));
    File sudokuConfigFile = new File(props.getProperty("sudoku_config_file"));
    File sudokuOutputFile = new File(props.getProperty("sudoku_output_file"));
    int port = Integer.parseInt(props.getProperty("server_port"));
    if(!solverScript.exists()) {
      throw new FileNotFoundException("Missing file: "+ solverScript.getName());
    }
    return new Config(solverScript, sudokuConfigFile, sudokuOutputFile, port);
  }

  private final Config config;

  public App(Config config) throws IOException {
    super(config.port);
    start(NanoHTTPD.SOCKET_READ_TIMEOUT, false);
    this.config = config;
    System.out.printf(
      "%nRunning Backend Sudoku Solver Web Server at http://localhost:%d/%n",
      config.port);
    System.out.println();
  }

  public static void main(String[] args) {
    try {
      Config config = loadConfig();
      new App(config);
    } catch (IOException ioe) {
      System.err.println("Couldn't start server:\n" + ioe);
    }
  }

  private File getSolverScript() { return config.solverScript; }

  private File getSudokuConfigFile() { return config.sudokuConfigFile; }

  private File getSudokuOutputFile() { return config.sudokuOutputFile; }

  @Override
  public Response serve(IHTTPSession session)
  {
    Map<String, String> files = new HashMap<String, String>();
    Method method = session.getMethod();
    if (Method.PUT.equals(method) || Method.POST.equals(method)) {
      try {
        session.parseBody(files);
      }
      catch (IOException ioe) {
        return newFixedLengthResponse(
            "SERVER INTERNAL ERROR: IOException: " + ioe.getMessage());
      }
      catch (ResponseException re) {
        return newFixedLengthResponse(
            "SERVER INTERNAL ERROR: ResponseException: " + re.getMessage());
      }
    }
    // get the POST body
    String postBody = files.get("postData");
    System.out.println("postBody: " + postBody);
    try {
      JSONParser parser = new JSONParser();
      JSONObject postRequestJson = (JSONObject) parser.parse(postBody);
      writeSudokuConfigFile(postRequestJson);
    }
    catch(ParseException e) {
      return newFixedLengthResponse(
          "SERVER INTERNAL ERROR: ParseException: " + e.getMessage());
    }
    catch(IOException e) {
      return newFixedLengthResponse(
          "SERVER INTERNAL ERROR: IOException: " + e.getMessage() + '\n');
    }
    try {
      String solverResults = runSolver();
      System.out.println(solverResults);
      Response response = newFixedLengthResponse(
        NanoHTTPD.Response.Status.OK,
        NanoHTTPD.MIME_PLAINTEXT,
        solverResults);
      response.addHeader("Access-Control-Allow-Origin", "*");
      return response;
    }
    catch(IOException e) {
      return newFixedLengthResponse(
        "SERVER INTERNAL ERROR: IOException: " + e.getMessage() + '\n');
    }
    catch(InterruptedException e) {
      return newFixedLengthResponse(
        "SERVER INTERNAL ERROR: InterruptedException: " + e.getMessage() + '\n');
    }
  }

  private String runSolver() throws IOException, InterruptedException {
    File sudokuOutputFile = getSudokuOutputFile();
    getSudokuOutputFile().delete();
    String command = getSolverScript().getCanonicalPath();
    execute(command);
    String solverResults = readFile(sudokuOutputFile);
    return solverResults;
  }

  private void writeSudokuConfigFile(JSONObject postRequestJson) throws IOException {
    File sudokuConfigFile = getSudokuConfigFile();
    sudokuConfigFile.delete();
    JSONObject configJson = createConfigJSON(postRequestJson);
    System.out.println("Writing JSON input to file: " + sudokuConfigFile);
    FileWriter writer = new FileWriter(sudokuConfigFile);
    configJson.writeJSONString(writer);
    writer.close();
  }
  
  
  @SuppressWarnings("unchecked")
  private JSONObject createConfigJSON(JSONObject postRequestJson) {
    JSONArray boardJson = (JSONArray) postRequestJson.get("board");
    JSONObject configJson = new JSONObject();
    File sudokuOutputFile = getSudokuOutputFile();
    configJson.put("input_board", boardJson);
    configJson.put("output_file", sudokuOutputFile.getName());
    return configJson;
  }


  private static void execute(String command)
      throws InterruptedException, IOException
  {
    System.out.println("Command: " + command);
    String[] cmdargs = {"bash", "-l", command};
    ProcessBuilder pb = new ProcessBuilder(cmdargs).inheritIO();
    pb.environment();
    Process process = pb.start();
    int exitValue = process.waitFor();
    if(exitValue != 0) {
      throw new IOException(String.format(
          "Error code %d returned from command: %s", exitValue, command));
    }
  }

  private static String readFile(File file) throws IOException {
    System.out.println("Reading file " + file.getAbsolutePath());
    BufferedReader br = new BufferedReader(new FileReader(file));
    StringBuffer sb = new StringBuffer();
    String line;
    while((line = br.readLine()) != null) {
      sb.append(line + '\n');
    }
    br.close();
    return sb.toString();
  }
}
