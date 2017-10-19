import React, { Component } from 'react';
import styled from 'styled-components/native';
import { observable } from 'mobx';
import { observer } from 'mobx-react';

const Zone = styled.View.attrs({
    cellsSize: props => parseInt(props.cellsSize) || 20,
    size: props => (9 * parseInt(props.cellsSize)) || 180,
}) `
    background-color: #9370DB;
    width: ${props => props.size};
    height: ${props => props.size};
`;

@observer
export default class ChessBoard extends Component {

    render() {
        return (
            <Zone cellsSize={this.props.cellsSize}>
            </Zone>
        )
    }

}