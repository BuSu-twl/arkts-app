import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';

interface NoticeReadFile {
  readIds: number[];
}

const NOTICE_READ_STORE: string = 'notice_read.json';

/** 消息通知已读 ID 持久化（沙箱 filesDir/notice_read.json） */
export class NoticePersistence {
  private static appContext: Context | null = null;

  static init(context: Context): void {
    NoticePersistence.appContext = context;
  }

  static ensureInit(context: Context): void {
    if (NoticePersistence.appContext === null) {
      NoticePersistence.init(context);
    }
  }

  private static getStorePath(): string {
    return `${NoticePersistence.appContext!.filesDir}/${NOTICE_READ_STORE}`;
  }

  private static encodeUtf8(text: string): ArrayBuffer {
    let encoder = new util.TextEncoder();
    return encoder.encodeInto(text).buffer;
  }

  private static decodeUtf8(buffer: ArrayBuffer): string {
    let decoder = new util.TextDecoder('utf-8', { ignoreBOM: true });
    return decoder.decodeWithStream(new Uint8Array(buffer));
  }

  private static fileExists(path: string): boolean {
    try {
      fs.statSync(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  private static readTextFile(path: string): string {
    let file = fs.openSync(path, fs.OpenMode.READ_ONLY);
    let stat = fs.statSync(path);
    let buffer = new ArrayBuffer(stat.size);
    fs.readSync(file.fd, buffer);
    fs.closeSync(file);
    return NoticePersistence.decodeUtf8(buffer);
  }

  private static writeTextFile(path: string, text: string): void {
    let buffer = NoticePersistence.encodeUtf8(text);
    let file = fs.openSync(path, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE | fs.OpenMode.TRUNC);
    fs.writeSync(file.fd, buffer);
    fs.closeSync(file);
  }

  private static containsId(ids: number[], id: number): boolean {
    for (let i = 0; i < ids.length; i++) {
      if (ids[i] === id) {
        return true;
      }
    }
    return false;
  }

  static loadReadIds(): number[] {
    if (NoticePersistence.appContext === null) {
      return [];
    }
    let path = NoticePersistence.getStorePath();
    try {
      if (!NoticePersistence.fileExists(path)) {
        return [];
      }
      let text = NoticePersistence.readTextFile(path);
      if (text.length === 0) {
        return [];
      }
      let parsed = JSON.parse(text) as NoticeReadFile;
      if (parsed.readIds === undefined) {
        return [];
      }
      return parsed.readIds;
    } catch (e) {
      console.error('NoticePersistence.loadReadIds failed:', JSON.stringify(e));
      return [];
    }
  }

  static saveReadIds(readIds: number[]): void {
    if (NoticePersistence.appContext === null) {
      return;
    }
    try {
      let payload: NoticeReadFile = { readIds: readIds };
      NoticePersistence.writeTextFile(NoticePersistence.getStorePath(), JSON.stringify(payload));
    } catch (e) {
      console.error('NoticePersistence.saveReadIds failed:', JSON.stringify(e));
    }
  }

  static isRead(id: number, seedRead: boolean): boolean {
    if (seedRead) {
      return true;
    }
    return NoticePersistence.containsId(NoticePersistence.loadReadIds(), id);
  }

  static markRead(id: number): void {
    let ids = NoticePersistence.loadReadIds();
    if (!NoticePersistence.containsId(ids, id)) {
      ids.push(id);
      NoticePersistence.saveReadIds(ids);
    }
  }

  static markAllRead(allIds: number[]): void {
    let ids = NoticePersistence.loadReadIds();
    for (let i = 0; i < allIds.length; i++) {
      if (!NoticePersistence.containsId(ids, allIds[i])) {
        ids.push(allIds[i]);
      }
    }
    NoticePersistence.saveReadIds(ids);
  }
}
