// VibrationUtil.ets
import vibrator from '@ohos.vibrator';
import { BusinessError } from '@kit.BasicServicesKit';

export class VibrationUtil {
  static async vibrate(duration: number): Promise<void> {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: duration
      }, {
        id: 0,
        usage: 'alarm' // The switch control is subject to the selected type.
      }, (error: BusinessError) => {
        if (error) {
          console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
          return;
        }
        console.info('Succeed in starting vibration');
      });
    } catch (error) {
    }
  }

  static vibrateForSuccess(): void {
    // Short success pattern
    vibrator.startVibration({
      type: 'time',
      duration: 100
    }, {
      id: 0,
      usage: 'alarm' // The switch control is subject to the selected type.
    }, (error: BusinessError) => {
      if (error) {
        console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
        return;
      }
      console.info('Succeed in starting vibration');
    });
  }

  static vibrateForFailure(): void {
    // Long failure pattern
    vibrator.startVibration({
      type: 'time',
      duration: 500
    }, {
      id: 0,
      usage: 'alarm' // The switch control is subject to the selected type.
    }, (error: BusinessError) => {
      if (error) {
        console.error(`Failed to start vibration. Code: ${error.code}, message: ${error.message}`);
        return;
      }
      console.info('Succeed in starting vibration');
    });
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