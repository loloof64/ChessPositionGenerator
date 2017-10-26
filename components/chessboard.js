import React, { Component } from 'react';
import { Image, PanResponder, Animated } from 'react-native';
import styled from 'styled-components/native';
import { observable } from 'mobx';
import { observer } from 'mobx-react';
import _ from 'underscore';
import { Chess } from 'chess.js';
import { pl, pd, nl, nd, bl, bd, rl, rd, ql, qd, kl, kd } from './chess_tiles';

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

const TurnIndicator = styled.View.attrs({
    size: props => parseInt(props.cellsSize) || 20,
    location: props => parseInt(props.cellsSize * 8.5)
}) `
    position: absolute;
    background-color: ${props => props.blackTurn ? '#000000' : '#FFFFFF'};
    width: ${props => props.size};
    height: ${props => props.size};
    left: ${props => props.location};
    top: ${props => props.location};
`;

const AnimatedImage = Animated.createAnimatedComponent(Image);

@observer
class Piece extends Component {

    constructor(props) {
        super(props);
        this.size = parseInt(props.size || 20);
        this.x = parseInt(props.x || 0);
        this.y = parseInt(props.y || 0);
        this.minXY = this.size * (0.5);
        this.maxXY = this.size * (7.5);
        this.midXY = (this.minXY + this.maxXY) / 2;
        this._position = new Animated.ValueXY();
        this._constrainedX = this._position.x.interpolate({
            inputRange: [this.minXY, this.midXY, this.maxXY],
            outputRange: [this.minXY, this.midXY, this.maxXY],
            extrapolate: 'clamp',
        });
        this._constrainedY = this._position.y.interpolate({
            inputRange: [this.minXY, this.midXY, this.maxXY],
            outputRange: [this.minXY, this.midXY, this.maxXY],
            extrapolate: 'clamp',
        });
        this._position.setValue({ x: this.x, y: this.y });
        this._panResponder = PanResponder.create({
            onStartShouldSetPanResponder: (event, gestureState) => {
                const nativeEvent = event.nativeEvent;

                let origFile = parseInt((nativeEvent.pageX - this.props.parentX - this.size * 0.5) / this.size);
                let origRank = 7 - parseInt((nativeEvent.pageY - this.props.parentY - this.size * 0.5) / this.size);
                if (this.props.reversed) {
                    origFile = 7 - origFile;
                    origRank = 7 - origRank;
                }

                //////////////////////////////////
                console.log(`${origFile} ${origRank}`)
                ///////////////////////////////////

                this._movedPiece = {
                    file: origFile,
                    rank: origRank,
                }
                return true;
            },
            onPanResponderGrant: (event, gestureState) => {
                this._position.setOffset({ x: this._position.x._value, y: this._position.y._value });
            },
            onPanResponderMove: (event, gesture) => {
                this._position.setValue({ x: gesture.dx, y: gesture.dy });
            },
            onPanResponderRelease: (e, gesture) => {
                this._movedPiece = undefined;
                this._position.flattenOffset()
            }
        });
    }

    render() {
        return <AnimatedImage
            style={{
                position: 'absolute',
                width: this.size,
                height: this.size,
                left: this._constrainedX,
                top: this._constrainedY
            }}
            {...this._panResponder.panHandlers }
            source={{ uri: this.props.sourceString }}
        />
    }
}

@observer
export default class ChessBoard extends Component {

    @observable _chess;
    @observable _position;

    @observable _x;
    @observable _y;

    constructor(props) {
        super(props);
        this._chess = new Chess(this.props.fen);
    }

    layoutCallBack(event) {
        this._x = event.nativeEvent.layout.x;
        this._y = event.nativeEvent.layout.y;
    }

    render() {
        return (
            <Zone
                onLayout={this.layoutCallBack.bind(this)}
                cellsSize={this.props.cellsSize}
            >
                {this.renderAllRanks()}
                {this.renderFileCoords(true)}
                {this.renderFileCoords(false)}
                {this.renderRankCoords(true)}
                {this.renderRankCoords(false)}
                {this.renderPlayerTurnIndicator()}
                {this.renderPieces()}
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

    renderPlayerTurnIndicator() {
        return (
            <TurnIndicator
                cellsSize={this.props.cellsSize}
                blackTurn={this._chess.turn() === 'b'}
            />
        );
    }

    renderPieces() {
        const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
        const ranks = ['1', '2', '3', '4', '5', '6', '7', '8'];

        return _.map(ranks, (currRank, currRankIndex) => {
            return _.map(files, (currFile, currFileIndex) => {
                const cellStr = `${currFile}${currRank}`
                let imageSource;
                let piece = this._chess.get(cellStr);

                if (piece) {
                    const randomKey = parseInt(Math.random() * 1000000000).toString();
                    switch (piece.type) {
                        case 'p': imageSource = piece.color === 'b' ? pd : pl; break;
                        case 'n': imageSource = piece.color === 'b' ? nd : nl; break;
                        case 'b': imageSource = piece.color === 'b' ? bd : bl; break;
                        case 'r': imageSource = piece.color === 'b' ? rd : rl; break;
                        case 'q': imageSource = piece.color === 'b' ? qd : ql; break;
                        case 'k': imageSource = piece.color === 'b' ? kd : kl; break;
                    }

                    return (
                        <Piece
                            key={randomKey}
                            size={this.props.cellsSize}
                            x={this.props.cellsSize * (this.props.reversed ? 7.5 - currFileIndex : currFileIndex + 0.5)}
                            y={this.props.cellsSize * (this.props.reversed ? currRankIndex + 0.5 : 7.5 - currRankIndex)}
                            parentX={this._x}
                            parentY={this._y}
                            reversed={this.props.reversed}
                            sourceString={imageSource}
                        />
                    );
                }

            });
        });
    }

}