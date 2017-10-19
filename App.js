/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import styled from 'styled-components/native';

const TopPanel = styled.View`
  flex: 1;
  flex-direction: column;
  justify-content: center;
  align-items: center;
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
  render() {
    return (
      <TopPanel>
        <Button>
          <ButtonText>
            Hello
          </ButtonText>
        </Button>
      </TopPanel>
    );
  }
}
