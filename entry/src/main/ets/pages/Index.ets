// Game.ets

import sensor from '@ohos.sensor';
import { BusinessError } from '@ohos.base';
import { GameLogic } from '../GameLogic';
import { VibrationUtil } from '../utils/VibrationUtil';
import AudioManager from '../utils/SoundManager';
import StorageManager from '../utils/StorageManager';
import { common } from '@kit.AbilityKit';

@Entry
@Component
struct GamePage {
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  @State gameLogic: GameLogic = new GameLogic();
  private audioManager: AudioManager = AudioManager.getInstance();
  private storageManager: StorageManager = StorageManager.getInstance();

  @State countdown: number = 0;
  @State score: number = 0;
  @State gameState: 'idle' | 'waiting' | 'active' | 'result' = 'idle';
  @State accelerometerData: string = '';
  @State highScore: number = 0;

  private sensorId: number = -1;
  private isSensorActive: boolean = false;

  async aboutToAppear() {
    this.storageManager.initialize(this.context);
    // Load high score
    this.highScore = await this.storageManager.getHighScore();
    this.gameLogic.setOnGameStart(() => {
      this.gameState = 'active';
      this.startAccelerometer();
      this.audioManager.playStartSound();
    });

    this.gameLogic.setOnGameEnd(async (finalScore: number) => {
      this.score = finalScore;

      if (finalScore > this.highScore) {
        await this.storageManager.saveHighScore(finalScore);
        this.highScore = finalScore;
        this.audioManager.playHighScoreSound();
      } else {
        this.audioManager.playEndSound();
      }

      this.gameState = 'result';
      this.stopAccelerometer();
    });
  }

  aboutToDisappear() {
    this.stopAccelerometer();
    this.audioManager.release();
  }

  build() {
    Column() {
      if (this.gameState === 'idle') {
        this.BuildIdleView()
      } else if (this.gameState === 'waiting') {
        this.BuildWaitingView()
      } else if (this.gameState === 'active') {
        this.BuildActiveView()
      } else {
        this.BuildResultView()
      }

      // Debug sensor data (can be removed in production)
      Text(this.accelerometerData)
        .fontSize(10)
        .opacity(0.7)
        .margin({ top: 20 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down && this.gameState === 'active') {
        this.handleTap();
      }
    })
  }

  @Builder BuildIdleView() {
    Column() {

      Text($r('app.string.title'))
        .fontSize(14)
        .opacity(0.8)
        .margin({ top: 20, bottom: 30 })

      Text($r('app.string.high_score', this.highScore))
        .fontSize(14)
        .opacity(0.8)
        .margin({ bottom: 30 })

      Button($r('app.string.start'))
        .width(120)
        .height(120)
        .fontSize(16)
        .borderRadius(60)
        .onClick(() => {
          this.startGame();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder BuildWaitingView() {
    Column() {
      Text($r('app.string.getready'))
        .fontSize(16)
        .margin({ bottom: 20 })
      Text(this.countdown.toString())
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Blue)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder BuildActiveView() {
    Column() {
      Text($r('app.string.punch'))
        .fontSize(18)
        .fontColor(Color.Red)
        .margin({ bottom: 10 })
      Text($r('app.string.score', this.score))
        .fontSize(16)
        .margin({ bottom: 20 })
      Text($r('app.string.punch'))
        .fontSize(12)
        .opacity(0.7)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder BuildResultView() {
    Column() {
      Text($r('app.string.roundover'))
        .fontSize(16)
        .margin({ bottom: 10 })
      Text($r('app.string.final_score', this.score))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Green)
        .margin({ bottom: 30 })

      Button($r('app.string.again'))
        .width(100)
        .onClick(() => {
          this.startGame();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  private startGame() {
    this.gameState = 'waiting';
    this.countdown = 3;
    this.score = 0;

    // Countdown timer
    let countdownInterval = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(countdownInterval);
        this.gameLogic.startRound();
      }
    }, 1000);
  }

  private handleTap() {
    const tapScore = this.gameLogic.registerTap();
    this.score = tapScore;
    VibrationUtil.vibrateForSuccess();
    this.audioManager.playTapSound();
  }

  private startAccelerometer() {
    try {
      sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
        // Update sensor data display
        this.accelerometerData = `x: ${data.x.toFixed(2)}, y: ${data.y.toFixed(2)}, z: ${data.z.toFixed(2)}`;

        // Detect shake gesture for alternative input
        if (this.detectShake(data)) {
          this.handleTap();
        }
      }, {
        interval: 1000
      });

      this.isSensorActive = true;
    } catch (error) {
      console.error('Failed to start accelerometer: ' + (error as BusinessError).message);
    }
  }

  private stopAccelerometer() {
    if (this.isSensorActive && this.sensorId !== -1) {
      sensor.off(1);
      this.isSensorActive = false;
      this.sensorId = -1;
    }
  }

  private detectShake(data: sensor.AccelerometerResponse): boolean {
    // Simple shake detection - calculate total acceleration
    const totalAcceleration = Math.sqrt(data.x * data.x + data.y * data.y + data.z * data.z);

    // Threshold for shake detection (adjust based on testing)
    const shakeThreshold = 15.0;

    return totalAcceleration > shakeThreshold && this.gameState === 'active';
  }
}