import React, { Component } from 'react';
import { Dimensions } from 'react-native';
import styled from 'styled-components/native';
import Spinner from 'react-native-loading-spinner-overlay';
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

const GroupView = styled.View`
`;

const ActivityIndicator = styled.ActivityIndicator`
  flex: 1
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

  @observable reversed = true;
  @observable loading = true;

  constructor() {
    super();
    const { height, width } = Dimensions.get('window');
    const minDimension = width < height ? width : height;
    this.cellsSize = parseInt(minDimension * 0.1);
  }

  componentDidMount() {
    setTimeout(() => this.loading = false, 1000);
  }

  renderZoneContent() {
    if (this.loading) {
      return <Spinner visible={true} color='red' textContent='Loading' />;
    }
    else {
      return (
        <GroupView>
          <Button onPress={() => this.reversed = !this.reversed}>
            <ButtonText>
              Reverse
            </ButtonText>
          </Button>
          <ChessBoard cellsSize={this.cellsSize} reversed={this.reversed} />
        </GroupView>
      );
    }
  }

  render() {
    return (
      <TopPanel>
        {this.renderZoneContent()}
      </TopPanel>
    )
  }
}
