import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import userData from '../../../mock/user.json';

interface UserDataFile {
  data: Object[];
}

const USER_STORE_NAME: string = 'user_data.json';

/** 用户数据持久化：读写应用沙箱 filesDir/user_data.json（结构与 mock/user.json 一致） */
export class UserPersistence {
  private static appContext: Context | null = null;

  static init(context: Context): void {
    UserPersistence.appContext = context;
  }

  static getStorePath(): string {
    return `${UserPersistence.appContext!.filesDir}/${USER_STORE_NAME}`;
  }

  static getDefaultUsers(): Object[] {
    return (userData as UserDataFile).data;
  }

  static fileExists(path: string): boolean {
    try {
      fs.statSync(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  static encodeUtf8(text: string): ArrayBuffer {
    let encoder = new util.TextEncoder();
    return encoder.encodeInto(text).buffer;
  }

  static decodeUtf8(buffer: ArrayBuffer): string {
    let decoder = new util.TextDecoder('utf-8', { ignoreBOM: true });
    return decoder.decodeWithStream(new Uint8Array(buffer));
  }

  static readTextFile(path: string): string {
    let file = fs.openSync(path, fs.OpenMode.READ_ONLY);
    let stat = fs.statSync(path);
    let buffer = new ArrayBuffer(stat.size);
    fs.readSync(file.fd, buffer);
    fs.closeSync(file);
    return UserPersistence.decodeUtf8(buffer);
  }

  static writeTextFile(path: string, text: string): void {
    let buffer = UserPersistence.encodeUtf8(text);
    let file = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
    fs.writeSync(file.fd, buffer);
    fs.closeSync(file);
  }

  /** 首次启动用 mock 初始化；之后始终读沙箱文件 */
  static loadUsers(): Object[] {
    let defaults = UserPersistence.getDefaultUsers();
    if (UserPersistence.appContext === null) {
      return defaults;
    }
    let path = UserPersistence.getStorePath();
    try {
      if (!UserPersistence.fileExists(path)) {
        UserPersistence.saveUsers(defaults);
        return defaults;
      }
      let text = UserPersistence.readTextFile(path);
      if (text.length === 0) {
        UserPersistence.saveUsers(defaults);
        return defaults;
      }
      let parsed = JSON.parse(text) as UserDataFile;
      if (parsed.data === undefined || parsed.data.length === 0) {
        UserPersistence.saveUsers(defaults);
        return defaults;
      }
      return parsed.data;
    } catch (e) {
      console.error('UserPersistence.loadUsers failed:', JSON.stringify(e));
      UserPersistence.saveUsers(defaults);
      return defaults;
    }
  }

  static saveUsers(users: Object[]): void {
    if (UserPersistence.appContext === null) {
      return;
    }
    try {
      let payload: UserDataFile = { data: users };
      let text = JSON.stringify(payload);
      UserPersistence.writeTextFile(UserPersistence.getStorePath(), text);
    } catch (e) {
      console.error('UserPersistence.saveUsers failed:', JSON.stringify(e));
    }
  }
}
