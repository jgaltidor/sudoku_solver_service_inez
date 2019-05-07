package jga.sudoku;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.Map;
import fi.iki.elonen.NanoHTTPD;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;

public class App extends NanoHTTPD
{
  public App() throws IOException {
    super(8080);
    start(NanoHTTPD.SOCKET_READ_TIMEOUT, false);
    System.out.println("\nRunning! Point your browsers to http://localhost:8080/ \n");
  }

  public static void main(String[] args) {
    try {
      new App();
    } catch (IOException ioe) {
      System.err.println("Couldn't start server:\n" + ioe);
    }
  }

  private static File solverSrcDir = new File(
      "/Users/johnaltidor/mywork/newprjs/sudoku_solver_inez_prj/sudoku_solver_service_inez/sudoku_solver_inez/src");

  @Override
  public Response serve(IHTTPSession session) {

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
    // Check that the POST body is valid JSON
    JSONParser parser = new JSONParser();
    JSONObject json;
    try {
      json = (JSONObject) parser.parse(postBody);
    }
    catch(ParseException e) {
      return newFixedLengthResponse(
          "SERVER INTERNAL ERROR: ParseException: " + e.getMessage());
    }
    File jsonInputFile = new File(solverSrcDir, "sudoku.json");
    jsonInputFile.delete();
    System.out.println("Writing JSON input to file: " + jsonInputFile);
    try {
      FileWriter writer = new FileWriter(jsonInputFile);
      json.writeJSONString(writer);
      writer.close();
    }
    catch(IOException e) {
      return newFixedLengthResponse(
          "SERVER INTERNAL ERROR: IOException: " + e.getMessage() + '\n');
    }
    File runSolverScript = new File(solverSrcDir, "run_solver.sh");
    try {
      File serverOutputFile = new File("server_output.json");
      serverOutputFile.delete();
      File solverOutputFile = new File(solverSrcDir, "output.json");
      solverOutputFile.delete();
      String command = runSolverScript.getCanonicalPath();
      execute(command);
      
      Files.copy(
        solverOutputFile.toPath(),
    	serverOutputFile.toPath(),
    	StandardCopyOption.REPLACE_EXISTING);
      String solverResults = readFile(serverOutputFile);
      /*
      StringBuffer rsb = new StringBuffer("<html><body>")
          .append("<p>solver results: ")
          .append(solverResults)
          .append("</p>")
          .append("</body></html>\n");
        
      return newFixedLengthResponse(rsb.toString());
      */
      return newFixedLengthResponse(solverResults + "\n");
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
    // Thread.sleep(10); // give time for command to finish writing file
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