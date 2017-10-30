import React, { Component } from 'react';
import { Image, Animated, PanResponder, Easing } from 'react-native';
import { observable } from 'mobx';
import { observer } from 'mobx-react';
import styled from 'styled-components/native';

const AnimatedImage = Animated.createAnimatedComponent(Image);

@observer
export default class Piece extends Component {

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

                const [origFile, origRank] = this.computeClickedCellCoordinates({
                    x: nativeEvent.pageX,
                    y: nativeEvent.pageY,
                });

                this._movedPiece = {
                    origFile,
                    origRank,
                }

                return true;
            },
            onPanResponderGrant: (event, gestureState) => {
                this._position.setOffset({ x: this._position.x._value, y: this._position.y._value });
            },
            onPanResponderMove: (event, gesture) => {
                this._position.setValue({ x: gesture.dx, y: gesture.dy });
            },
            onPanResponderRelease: (event, gesture) => {
                const nativeEvent = event.nativeEvent;

                const [endFile, endRank] = this.computeClickedCellCoordinates({
                    x: nativeEvent.pageX,
                    y: nativeEvent.pageY,
                });

                const moveSuccess = this.props.doMove({
                    ...this._movedPiece,
                    endFile, endRank
                });

                if (moveSuccess) {
                    this.props.forceBoardRefresh();
                }
                else {
                    const origX = parseInt(this.size *
                        (this.props.reversed ? 7.5 - this._movedPiece.origFile : this._movedPiece.origFile + 0.5));
                    const origY = parseInt(this.size *
                        (this.props.reversed ? 0.5 + this._movedPiece.origRank : 7.5 - this._movedPiece.origRank));


                    this._position.flattenOffset();

                    // Act as if we have released from the centre of where the piece appears
                    // on screen, rather than potentially outside the constrained area
                    // (Thanks to Rob Hogan on StackOverflow)
                    this._position.setValue({ x: this._constrainedX.__getValue(), y: this._constrainedY.__getValue() });

                    Animated.timing(
                        this._position,
                        {
                            toValue: { x: origX, y: origY },
                            duration: 400,
                            delay: 0,
                            easing: Easing.linear
                        }
                    ).start();
                }

                this._movedPiece = undefined;
            }
        });
    }

    computeClickedCellCoordinates(eventPage) {
        let file = parseInt((eventPage.x - this.props.parentX - this.size * 0.5) / this.size);
        let rank = 7 - parseInt((eventPage.y - this.props.parentY - this.size * 0.5) / this.size);
        if (this.props.reversed) {
            file = 7 - file;
            rank = 7 - rank;
        }
        return [file, rank];
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