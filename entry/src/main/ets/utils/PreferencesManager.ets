import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

export class PreferencesManager {
  private static instance: PreferencesManager;
  private prefs: preferences.Preferences | null = null;
  private context: common.UIAbilityContext | null = null;

  private constructor() {}

  public static getInstance(): PreferencesManager {
    if (!PreferencesManager.instance) {
      PreferencesManager.instance = new PreferencesManager();
    }
    return PreferencesManager.instance;
  }

  public async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    this.prefs = await preferences.getPreferences(this.context, 'myPrefs');
  }

  public async save(key: string, value: preferences.ValueType): Promise<void> {
    if (!this.prefs) { return };
    await this.prefs.put(key, value);
    await this.prefs.flush();
  }

  public async get(key: string, defaultValue: preferences.ValueType): Promise<preferences.ValueType> {
    if (!this.prefs) { return defaultValue };
    return await this.prefs.get(key, defaultValue);
  }

  public async delete(key: string): Promise<void> {
    if (!this.prefs) { return };
    await this.prefs.delete(key);
    await this.prefs.flush();
  }

  public async clear(): Promise<void> {
    if (!this.prefs) { return };
    await this.prefs.clear();
    await this.prefs.flush();
  }
}