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
      data  : props.data
    };
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    let newValue = event.target.value;
    this.state.data.updateCell(newValue);
    this.setState({
      data: {
        value       : newValue,
        updateCell  : this.state.data.updateCell
      }
    });
  }

  render() {
    return (
      <input className  = "gridCell inputcell"
             type       = "text"
             maxLength  = "1"
             value      = {this.state.data.value}
             onChange   = {this.handleChange}>
      </input>
    );
  }

  getValue() {
    return this.state.value;
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
        <RowLabel label={this.state.rowlabel} />
        <Cell data = {this.state.row[0]} />
        <Cell data = {this.state.row[1]} />
        <Cell data = {this.state.row[2]} />
        <ColumnSeparator />
        <Cell data = {this.state.row[3]} />
        <Cell data = {this.state.row[4]} />
        <Cell data = {this.state.row[5]} />
        <ColumnSeparator />
        <Cell data = {this.state.row[6]} />
        <Cell data = {this.state.row[7]} />
        <Cell data = {this.state.row[8]} />
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
      rows: props.rows
    };
  }

  render() {
    return (
      <div className="grid">
        <TitleRow />
        <RowSeparator />
        <GridRow rowlabel="A" row={this.state.rows[0]} />
        <GridRow rowlabel="B" row={this.state.rows[1]} />
        <GridRow rowlabel="C" row={this.state.rows[2]} />
        <SquareRowSeparator />
        <GridRow rowlabel="D" row={this.state.rows[3]} />
        <GridRow rowlabel="E" row={this.state.rows[4]} />
        <GridRow rowlabel="F" row={this.state.rows[5]} />
        <SquareRowSeparator />
        <GridRow rowlabel="G" row={this.state.rows[6]} />
        <GridRow rowlabel="H" row={this.state.rows[7]} />
        <GridRow rowlabel="I" row={this.state.rows[8]} />
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

  render() {
    return (
      <div className="button rounded response-box"
        >{this.state.game.getResponse()}</div>
    );
  }
}

class Game extends React.Component
{
  constructor(props) {
    super(props);
    const rows = new Array(9);
    for(let i = 0; i < rows.length; i++) {
      rows[i] = new Array(9);
      for(let j = 0; j < rows[i].length; j++) {
        rows[i][j] = {
          value      : '',
          updateCell : (val) => this.updateCell(i, j, val)
        };
      }
    }
    this.state = {
      rows     : rows,
      response : 'response'
    };
  }

  updateCell(row, col, val) {
    var rows = new Array(this.state.rows.length);
    for(var i = 0; i < rows.length; i++) {
      rows[i] = this.state.rows[i].slice();
    }
    rows[row][col] = {
      value      : val,
      updateCell : rows[row][col].updateCell,
    };
    this.setState({
      rows     : rows,
      response : this.state.response
    });
  }

  getCellValue(row, col) {
    return this.state.rows[row][col].value;
  }

  handleSolveClick() {
    this.setState({
      rows     : this.state.rows,
      response : this.getCellValue(0, 0)
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
            <Grid rows={this.state.rows} />
          </div>
          <div className="right-box">
            <ButtonArea solveClick = {() => this.handleSolveClick()} />
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
      solveClick : props.solveClick
    }
  }

  render() {
    return (
      <div className="buttonsContainer">
        <fieldset id="buttonArea">
          <legend id="buttonAreaLegend">Features</legend>
          <button className = "button rounded"
               onClick   = {() => this.state.solveClick()} >Solve</button>
          <div style={{clear: 'both', height: '20px'}}></div>
          <div className = "button rounded">Clear</div>
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
