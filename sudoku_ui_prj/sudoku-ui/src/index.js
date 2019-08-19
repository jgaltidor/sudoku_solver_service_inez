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
    this.state = {value: ''};
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    this.setState({value: event.target.value});
  }

  render() {
    return (
      <input className = "gridCell inputcell"
            type       = "text"
            maxLength  = "1" 
            value      = {this.state.value}
            onChange   = {this.handleChange}>
      </input>
    );
  }
}

function ColumnSeparator() {
  return (
   <div className = "gridColumnSeparator"></div>
  );
}


function GridRow(props) {
  return (
    <div className = "gridRow" >
      <RowLabel label={props.rowlabel} />
      <Cell />
      <Cell />
      <Cell />
      <ColumnSeparator />
      <Cell />
      <Cell />
      <Cell />
      <ColumnSeparator />
      <Cell />
      <Cell />
      <Cell />
    </div>
  );
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

function Grid() {
  return (
    <div className="grid">
      <TitleRow />
      <RowSeparator />
      <GridRow rowlabel="A" />
      <GridRow rowlabel="B" />
      <GridRow rowlabel="C" />
      <SquareRowSeparator />
      <GridRow rowlabel="D" />
      <GridRow rowlabel="E" />
      <GridRow rowlabel="F" />
      <SquareRowSeparator />
      <GridRow rowlabel="G" />
      <GridRow rowlabel="H" />
      <GridRow rowlabel="I" />            
    </div>
  );
}

function ButtonArea() {
  return (
    <div className="buttonsContainer">
      <fieldset id="buttonArea">
        <legend id="buttonAreaLegend">Features</legend>
        <div className = "button rounded">Solve</div>
        <div style={{clear: 'both', height: '20px'}}></div>
        <div className = "button rounded">Clear</div>
      </fieldset>
    </div>
  );
}

class Game extends React.Component
{
  render() {
    return (
      <div className="root-box blue-box">
        <div className="pageHeaderTitle">Sudoku Solver</div>
        <div style={{clear: 'both'}}></div>
        <div className="mainContent">
          <Grid />
          <ButtonArea />
        </div>
      </div>
    );
  }
}

ReactDOM.render(<Game />, document.getElementById('root'));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
