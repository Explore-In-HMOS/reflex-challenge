// VibrationUtil.ets
import vibrator from '@ohos.vibrator';

export class VibrationUtil {
  static async vibrate(duration: number): Promise<void> {
    try {
      await vibrator.vibrate(duration);
    } catch (error) {
      console.error('Vibration failed: ' + error);
    }
  }

  static vibrateForSuccess(): void {
    // Short success pattern
    vibrator.vibrate(100);
  }

  static vibrateForFailure(): void {
    // Long failure pattern
    vibrator.vibrate(500);
  }

  static async vibratePattern(durations: number[]): Promise<void> {
    for (let duration of durations) {
      await VibrationUtil.vibrate(duration);
      await VibrationUtil.delay(150);
    }
  }

  private static delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}