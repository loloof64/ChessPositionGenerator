import React, { Component } from 'react';
import styled from 'styled-components/native';
import { observable } from 'mobx';
import { observer } from 'mobx-react';
import _ from 'underscore';

const Zone = styled.View.attrs({
    cellsSize: props => parseInt(props.cellsSize) || 20,
    size: props => (9 * parseInt(props.cellsSize)) || 180,
}) `
    background-color: #9370DB;
    width: ${props => props.size};
    height: ${props => props.size};
`;

const Cell = styled.View.attrs({
    size: props => parseInt(props.cellsSize) || 20,
}) `
    position: absolute;
    width: ${props => props.size};
    height: ${props => props.size};
    left: ${props => parseInt(props.size * ((props.file || 0) + 0.5))}
    top: ${props => parseInt(props.size * (7.5 - (props.rank || 0)))}
`;

const WhiteCell = Cell.extend`
    background-color: #EEE8AA;
`;

const BlackCell = Cell.extend`
    background-color: #8B4513;
`;

const Coord = styled.Text.attrs({
    size: props => parseInt(props.cellsSize) || 20
}) `
    font-weight: bold;
    font-size: ${props => parseInt(props.size * 0.5)}
    color: #FFFFFF;
    position: absolute;
`;

const FileCoord = Coord.extend`
    left: ${props => parseInt(props.size * ((props.file || 0) + 0.8))}
    top: ${props => parseInt(props.size * (props.areOnTop ? -0.10 : 8.40))}
`;

const RankCoord = Coord.extend`
    top: ${props => parseInt(props.size * ((props.rank || 0) + 0.7))}
    left: ${props => parseInt(props.size * (props.areOnTop ? 0.10 : 8.60))}
`;

@observer
export default class ChessBoard extends Component {

    render() {
        return (
            <Zone cellsSize={this.props.cellsSize}>
                {this.renderAllRanks()}
                {this.renderFileCoords(true)}
                {this.renderFileCoords(false)}
                {this.renderRankCoords(true)}
                {this.renderRankCoords(false)}
            </Zone>
        )
    }

    renderAllRanks() {
        const ranks = [0, 1, 2, 3, 4, 5, 6, 7];
        return _.map(ranks, (currRank) => this.renderRank(currRank));
    }

    renderRank(rank) {
        const files = [0, 1, 2, 3, 4, 5, 6, 7];
        return _.map(files, (currFile) => {
            const randomKey = parseInt(Math.random() * 1000000000).toString();
            if ((currFile + rank) % 2 == 0) {
                return (
                    <BlackCell
                        key={randomKey}
                        file={currFile}
                        rank={rank}
                        cellsSize={this.props.cellsSize}
                    />
                );
            }
            else {
                return (
                    <WhiteCell
                        key={randomKey}
                        file={currFile}
                        rank={rank}
                        cellsSize={this.props.cellsSize}
                    />
                );
            }
        });
    }

    renderFileCoords(areOnTop) {
        let filesCoords = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
        if (this.props.reversed) {
            filesCoords = filesCoords.reverse();
        }
        return _.map(filesCoords, (currFileCoord, currFile) => {
            const randomKey = parseInt(Math.random() * 1000000000).toString();
            return (
                <FileCoord
                    key={randomKey}
                    file={currFile}
                    areOnTop={areOnTop}
                    cellsSize={this.props.cellsSize}
                >
                    {currFileCoord}
                </FileCoord>
            );
        });
    }

    renderRankCoords(areOnTop) {
        let rankCoords = ['8', '7', '6', '5', '4', '3', '2', '1'];
        if (this.props.reversed) {
            rankCoords = rankCoords.reverse();
        }
        return _.map(rankCoords, (currRankCoord, currRank) => {
            const randomKey = parseInt(Math.random() * 1000000000).toString();
            return (
                <RankCoord
                    key={randomKey}
                    rank={currRank}
                    areOnTop={areOnTop}
                    cellsSize={this.props.cellsSize}
                >
                    {currRankCoord}
                </RankCoord>
            );
        });
    }

}