import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
//import axios from "axios"
import daten from './data.js'
console.log(daten);
class App extends Component {
  state = {
      data: []
  }

  componentDidMount(){
      this.setState({data: daten})
  }

  render() {
    return (
      <div className="App">
          {this.state.data.map(player => {
              return <div key={player.id}>{Object.keys(player).map((col,i) => {
                  return <span key={player.id+"&"+i}>{player[col]}</span>
              })}</div>
          })}
      </div>
    );
  }
}

export default App;
