import React, { Component } from 'react';
import { Dimensions } from 'react-native';
import styled from 'styled-components/native';
import { observable } from 'mobx';
import { observer } from 'mobx-react';

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
  flex-direction: row;
  justify-content: center;
  align-items: center;
  margin: 10px;
`;

const ButtonText = styled.Text`
  color: white;
  font-size: 20px;
  margin: 10px;
`;

@observer
export default class App extends Component {

  @observable reversed;

  constructor() {
    super();
    const { height, width } = Dimensions.get('window');
    const minDimension = width < height ? width : height;
    this.cellsSize = parseInt(minDimension * 0.1);
    this.reversed = true;
  }

  render() {
    return (
      <TopPanel>
        <Button onPress={() => this.reversed = !this.reversed}>
          <ButtonText>
            Reverse
          </ButtonText>
        </Button>
        <ChessBoard cellsSize={this.cellsSize} reversed={this.reversed} />
      </TopPanel>
    );
  }
}
