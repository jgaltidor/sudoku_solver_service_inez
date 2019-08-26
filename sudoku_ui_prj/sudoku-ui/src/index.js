import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';

import * as serviceWorker from './serviceWorker';

function ColumnLabel(props) {
  return (
    <div className = "gridCell gridLabel gridColumnLabel border" >{props.label}</div>
  );
}

function SquareColumnSeparator() {
  return (
    <div className = "gridColumnSeparator" />
  );
}

function RowLabel(props) {
  return (
    <div className = "gridCell gridLabel gridRowLabel border" >{props.label}</div>
  );
}

function RowSeparator() {
  return (
    <div style={{clear: 'both'}} />
  );
}

function TitleRow() {
  return (
    <div className = "gridRow" >
      <ColumnLabel label="" />
      <ColumnLabel label="1" />
      <ColumnLabel label="2" />
      <ColumnLabel label="3" />
      <SquareColumnSeparator />
      <ColumnLabel label="4" />
      <ColumnLabel label="5" />
      <ColumnLabel label="6" />
      <SquareColumnSeparator />
      <ColumnLabel label="7" />
      <ColumnLabel label="8" />
      <ColumnLabel label="9" />
    </div>
  );
}

class Cell extends React.Component
{
  constructor(props) {
    super(props);
    this.state = {
      row   : props.coordinate.row,
      col   : props.coordinate.col,
      game  : props.coordinate.game,
    };
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    let newValue = event.target.value;
    let row = this.state.row;
    let col = this.state.col;
    this.state.game.updateCell(row, col, newValue);
  }

  render() {
    return (
      <input className  = "gridCell inputcell"
             type       = "text"
             maxLength  = "1"
             value      = {this.getValue()}
             onChange   = {this.handleChange}>
      </input>
    );
  }

  getValue() {
    const row  = this.state.row;
    const col  = this.state.col;
    const game = this.state.game;
    return game.getCellValue(row, col);
  }
}

function ColumnSeparator() {
  return (
    <div className = "gridColumnSeparator"></div>
  );
}


class GridRow extends React.Component
{
  constructor(props) {
    super(props);
    this.state = {
      rowlabel  : props.rowlabel,
      row       : props.row,
    }
  }

  render() {
    return (
      <div className = "gridRow" >
        <RowLabel label  = {this.state.rowlabel} />
        <Cell coordinate = {this.state.row[0]} />
        <Cell coordinate = {this.state.row[1]} />
        <Cell coordinate = {this.state.row[2]} />
        <ColumnSeparator />
        <Cell coordinate = {this.state.row[3]} />
        <Cell coordinate = {this.state.row[4]} />
        <Cell coordinate = {this.state.row[5]} />
        <ColumnSeparator />
        <Cell coordinate = {this.state.row[6]} />
        <Cell coordinate = {this.state.row[7]} />
        <Cell coordinate = {this.state.row[8]} />
      </div>
    );
  }
}

function SquareRowSeparator() {
  return (
    <div>
      <RowSeparator />
      <div className = "gridRowSeparator" />
      <RowSeparator />
    </div>
  );
}

class Grid extends React.Component
{
  constructor(props) {
    super(props);
    this.state = {
      coordinates: props.coordinates
    };
  }

  render() {
    return (
      <div className="grid">
        <TitleRow />
        <RowSeparator />
        <GridRow rowlabel="A" row={this.state.coordinates[0]} />
        <GridRow rowlabel="B" row={this.state.coordinates[1]} />
        <GridRow rowlabel="C" row={this.state.coordinates[2]} />
        <SquareRowSeparator />
        <GridRow rowlabel="D" row={this.state.coordinates[3]} />
        <GridRow rowlabel="E" row={this.state.coordinates[4]} />
        <GridRow rowlabel="F" row={this.state.coordinates[5]} />
        <SquareRowSeparator />
        <GridRow rowlabel="G" row={this.state.coordinates[6]} />
        <GridRow rowlabel="H" row={this.state.coordinates[7]} />
        <GridRow rowlabel="I" row={this.state.coordinates[8]} />
      </div>
    );
  }
}

class ResponseArea extends React.Component
{
  constructor(props) {
    super(props);
    this.state = {
      game : props.game
    };
  }

  getResponse() {
    return this.state.game.getResponse();
  }

  render() {
    return (
      <div className="button rounded response-box"
        >{this.getResponse()}</div>
    );
  }
}

class Game extends React.Component
{
  constructor(props) {
    super(props);
    const coordinates = this.createCellCoordinates();
    const values = this.createClearCellValues();
    const response = this.getInitialResponse();
    this.state = {
      coordinates   : coordinates,
      values        : values,
      response      : response
    };
  }

  createClearCellValues() {
    const values = new Array(9);
    for(let i = 0; i < values.length; i++) {
      values[i] = new Array(9);
      for(let j = 0; j < values[i].length; j++) {
        values[i][j] = '';
      }
    }
    return values;
  }

  createCellCoordinates() {
    const coordinates = new Array(9);
    for(let i = 0; i < coordinates.length; i++) {
      coordinates[i] = new Array(9);
      for(let j = 0; j < coordinates[i].length; j++) {
        coordinates[i][j] = this.createCellCoordinate(i, j);
      }
    }
    return coordinates;
  }

  createCellCoordinate(row, col) {
    return {
      row        : row,
      col        : col,
      game       : this
    };
  }

  getInitialResponse() {
    return 'response';
  }

  cloneValues() {
    const values = new Array(this.state.values.length);
    for(let i = 0; i < values.length; i++) {
      values[i] = new Array(this.state.values[i].length);
      for(let j = 0; j < values[i].length; j++) {
        values[i][j] = this.getCellValue(i, j);
      }
    }
    return values;
  }

  updateCell(row, col, value) {
    const values = this.cloneValues();
    values[row][col] = value;
    this.setState({
      values        : values,
      coordinates   : this.state.coordinates,
      response      : this.state.response
    });
  }

  getCellValue(row, col) {
    return this.state.values[row][col];
  }

  handleSolveClick() {
    this.fetchSudokuSolution();
    const response = this.getCellValue(0, 0);
    this.setState({
      response      : response,
      values        : this.state.values,
      coordinates   : this.state.coordinates
    });
  }

  handleClearClick() {
    const values    = this.createClearCellValues();
    const response  = this.getInitialResponse();
    this.setState({
      values        : values,
      response      : response,
      coordinates   : this.state.coordinates
    });
  }

  getCellNumber(row, col) {
    let value = this.getCellValue(row, col);
    let num = parseInt(value, 10);
    if(num >= 1 && num <= 9) return num;
    else return 0;
  }

  jsonOfBoard() {
    let rows = new Array(this.state.values.length);;
    for(let i = 0; i < rows.length; i++) {
      rows[i] = new Array(this.state.values[i].length);
      for(let j = 0; j < rows[i].length; j++) {
        rows[i][j] = this.getCellNumber(i, j);
      }
    }
    return {'board': rows};
  }

  fetchSudokuSolution() {
    let inputBoardJSON = this.jsonOfBoard();
    let inputBoardStr = JSON.stringify(inputBoardJSON);
    console.log(inputBoardStr);
    fetch(
      'http://localhost:8080',
      {
        method  : 'post',
        headers : { 'Content-Type': 'text/plain' },
        body: inputBoardStr
      }
    )
    .then((response) => {
      if(response.ok) {
        return response.json();
      } else {
        throw new Error(response.statusText);
      }
    })
    .then((responseJSON) => {
      console.log("responseJSON.has_solution: " + responseJSON.has_solution);
    })
    .catch((error) => {
      console.error(error);
    });
  }

  getResponse() {
    return this.state.response;
  }

  render() {
    return (
      <div className="root-box blue-box">
        <div className="pageHeaderTitle">Sudoku Solver</div>
        <div style={{clear: 'both'}}></div>
        <div className="mainContent">
          <div className="left-box">
            <Grid coordinates={this.state.coordinates} />
          </div>
          <div className="right-box">
            <ButtonArea
              solveClick = {() => this.handleSolveClick()}
              clearClick = {() => this.handleClearClick()}
            />
            <div style={{clear: 'both', height: '20px'}}></div>
            <ResponseArea game = {this} />
          </div>
        </div>
      </div>
    );
  }
}

class ButtonArea extends React.Component
{
  constructor(props) {
    super(props);
    this.state = {
      solveClick : props.solveClick,
      clearClick : props.clearClick
    }
  }

  render() {
    return (
      <div className="buttonsContainer">
        <fieldset id="buttonArea">
          <legend id="buttonAreaLegend">Features</legend>
          <button
            className = "button rounded"
            onClick   = {() => this.state.solveClick()}
            >Solve</button>
          <div style ={{clear: 'both', height: '20px'}}></div>
          <button
            className = "button rounded"
            onClick   = {() => this.state.clearClick()}
            >Clear</button>
        </fieldset>
      </div>
    );
  }
}

ReactDOM.render(<Game />, document.getElementById('root'));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
