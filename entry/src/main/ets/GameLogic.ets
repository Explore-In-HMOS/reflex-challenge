// GameLogic.ets
import { VibrationUtil } from './utils/VibrationUtil';

export class GameLogic {
  private roundStartTime: number = 0;
  private reactionTime: number = 0;
  private onGameStart: () => void = () => {};
  private onGameEnd: (score: number) => void = () => {};
  private vibrationPattern: number[] = [];
  private expectedTapCount: number = 0;
  private actualTapCount: number = 0;

  constructor() {
    this.generateVibrationPattern();
  }

  setOnGameStart(callback: () => void) {
    this.onGameStart = callback;
  }

  setOnGameEnd(callback: (score: number) => void) {
    this.onGameEnd = callback;
  }

  startRound() {
    this.roundStartTime = new Date().getTime();
    this.actualTapCount = 0;
    this.generateVibrationPattern();
    this.onGameStart();

    // Start vibration sequence after random delay (1-2 seconds)
    const ms: number = Date.now();
    const rnd = ms % 10
    const randomDelay = 1000 + rnd * 1000;
    setTimeout(() => {
      this.playVibrationPattern();
    }, randomDelay);
  }

  private generateVibrationPattern() {
    // Generate 1-3 vibration pulses with random timing
    const ms: number = Date.now();
    const rnd = ms % 10
    this.expectedTapCount = Math.floor(rnd * 3) + 1;
    this.vibrationPattern = [];

    for (let i = 0; i < this.expectedTapCount; i++) {
      const ms: number = Date.now();
      const rnd = ms % 10
      this.vibrationPattern.push(100 + rnd * 200); // 100-300ms vibrations
    }
  }

  private async playVibrationPattern() {
    for (let duration of this.vibrationPattern) {
      await VibrationUtil.vibrate(duration);
      const ms: number = Date.now();
      const rnd = ms % 10
      await this.delay(200 + rnd * 300); // Random gaps between vibrations
    }
  }

  registerTap(): number {
    this.actualTapCount++;
    const currentTime = new Date().getTime();
    this.reactionTime = currentTime - this.roundStartTime;

    // Calculate accuracy score
    const accuracy = this.calculateAccuracy();
    const speedScore = Math.max(0, 1000 - this.reactionTime);

    const totalScore = Math.floor(speedScore * accuracy);

    // Check if round should end
    if (this.actualTapCount >= this.expectedTapCount) {
      setTimeout((): void => this.endRound(totalScore), 500);
    }

    return totalScore;
  }

  private calculateAccuracy(): number {
    const tapAccuracy = this.expectedTapCount > 0 ?
      this.actualTapCount / this.expectedTapCount : 1;
    return Math.min(1, tapAccuracy);
  }

  private endRound(finalScore: number) {
    this.onGameEnd(finalScore);
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}