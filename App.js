import React, { Component } from 'react';
import { Dimensions } from 'react-native';
import styled from 'styled-components/native';

import ChessBoard from './components/chessboard';

const TopPanel = styled.View`
  flex: 1;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background-color: #CCFFCC;
`;

const Button = styled.TouchableHighlight`
  background-color: #6612FF;
  width: 60px;
  flex-direction: row;
  justify-content: center;
  align-items: center;
`;

const ButtonText = styled.Text`
  color: white;
`;

export default class App extends Component {

  constructor() {
    super();
    const { height, width } = Dimensions.get('window');
    const minDimension = width < height ? width : height;
    this.cellsSize = parseInt(minDimension * 0.1);
  }

  render() {
    return (
      <TopPanel>
        <ChessBoard cellsSize={this.cellsSize} reversed />
      </TopPanel>
    );
  }
}
