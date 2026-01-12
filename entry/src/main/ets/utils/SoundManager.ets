// AudioManager.ets
import audio from '@ohos.multimedia.audio';
import { BusinessError } from '@ohos.base';

class AudioManager {
  private static instance: AudioManager | null = null;
  private audioRenderer: audio.AudioRenderer | null = null;
  private isInitialized: boolean = false;
  private isMuted: boolean = false;
  private isPlaying: boolean = false;
  private sampleRate = 44100;

  private constructor() {}

  static getInstance(): AudioManager {
    if (!AudioManager.instance) {
      AudioManager.instance = new AudioManager();
    }
    return AudioManager.instance;
  }

  async initialize(): Promise<void> {
    if (this.isInitialized) { return; }

    try {
      const audioStreamInfo: audio.AudioStreamInfo = {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_44100,
        channels: audio.AudioChannel.CHANNEL_1,
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_U8,
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
      };

      const audioRendererOptions: audio.AudioRendererOptions = {
        streamInfo: audioStreamInfo,
        rendererInfo: {
          usage: audio.StreamUsage.STREAM_USAGE_GAME,
          rendererFlags: 0
        }
      };

      this.audioRenderer = await audio.createAudioRenderer(audioRendererOptions);
      await this.audioRenderer.start();
      this.isInitialized = true;
      console.info('AudioManager initialized successfully');
    } catch (error) {
      console.error('Failed to initialize AudioManager: ' + (error as BusinessError).message);
    }
  }

  async playTapSound(): Promise<void> {
    if (this.isMuted) { return; }
    await this.playTone(800, 50);
  }

  async playCountdownSound(): Promise<void> {
    if (this.isMuted) { return; }
    await this.playTone(600, 100);
  }

  async playStartSound(): Promise<void> {
    if (this.isMuted) { return; }
    await this.playTone(1000, 150);
  }

  async playEndSound(): Promise<void> {
    if (this.isMuted) { return; }
    await this.playTone(400, 200);
  }

  async playHighScoreSound(): Promise<void> {
    if (this.isMuted) { return; }

    await this.playTone(800, 100);
    await this.delay(50);
    await this.playTone(1000, 100);
    await this.delay(50);
    await this.playTone(1200, 200);
  }

  async playErrorSound(): Promise<void> {
    if (this.isMuted) { return; }
    await this.playTone(300, 150);
    await this.delay(50);
    await this.playTone(300, 150);
  }

  private async playTone(frequency: number, duration: number): Promise<void> {
    if (this.isPlaying) {
      console.warn('Audio is already playing.');
      return;
    }
    this.isPlaying = true;

    try {
      const audioRendererOptions: audio.AudioRendererOptions = {
        streamInfo: {
          samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_44100,
          channels: audio.AudioChannel.CHANNEL_1,
          sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_F32LE,
          encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW
        },
        rendererInfo: {
          usage: audio.StreamUsage.STREAM_USAGE_RINGTONE,
          rendererFlags: 0
        }
      };

      this.audioRenderer = await audio.createAudioRenderer(audioRendererOptions);

      this.audioRenderer.on('writeData', () => {

        const sampleRate = 44100;
        if (!this.audioRenderer) {return;}

        try {

          let bufferSize = Math.floor((duration / 1000) * sampleRate);
          const buffer = new ArrayBuffer(bufferSize);
          const floatView = new Float32Array(buffer);

          const amplitude = 0.2;
          const omega = 2 * Math.PI * frequency / sampleRate;

          const samplesToGenerate = bufferSize / 4;

          for (let i = 0; i < samplesToGenerate; i++) {
            floatView[i] = amplitude * Math.sin(omega * i);
          }

        } catch (error) {
          console.error('Error in writeData callback:', error);
        }
      });

      await this.audioRenderer.start();

      setTimeout(async () => {
        await this.stopPlayback();
      }, duration);

    } catch (error) {
      console.error('Error starting audio playback:', error);
      this.isPlaying = false;
    }
  }

  private async stopPlayback(): Promise<void> {
    if (this.audioRenderer) {
      try {
        this.audioRenderer.off('writeData');

        await this.audioRenderer.stop();
        await this.audioRenderer.release();
        this.audioRenderer = null;
      } catch (error) {
        console.error('Error stopping playback:', error);
      } finally {
        this.isPlaying = false;
      }
    }
  }

  setMuted(muted: boolean): void {
    this.isMuted = muted;
  }

  isAudioMuted(): boolean {
    return this.isMuted;
  }

  private delay(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  async release(): Promise<void> {
    if (this.audioRenderer) {
      try {
        await this.audioRenderer.stop();
        await this.audioRenderer.release();
        this.audioRenderer = null;
        this.isInitialized = false;
        console.info('AudioManager released');
      } catch (error) {
        console.error('Failed to release AudioManager: ' + (error as BusinessError).message);
      }
    }
  }
}

export default AudioManager;