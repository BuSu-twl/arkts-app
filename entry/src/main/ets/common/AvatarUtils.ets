/** 头像资源：默认 avatars/img.png；系统推荐 avatars/img/* */
export class AvatarUtils {
  /** 存入 user.avatar 的默认头像标识 */
  static readonly DEFAULT_AVATAR_STORED: string = 'img.png';
  /** $rawfile 默认头像路径 */
  static readonly DEFAULT_AVATAR_RAW: string = 'avatars/img.png';

  /** 编辑页可选的系统推荐头像（rawfile 相对路径） */
  static readonly SYSTEM_PRESET_RAW_PATHS: string[] = [
    'avatars/img/01.jpg',
    'avatars/img/02.jpg',
    'avatars/img/03.png',
    'avatars/img/04.png',
    'avatars/img/05.png',
    'avatars/img/06.jpg',
  ];

  static isDefaultAvatar(stored: string): boolean {
    if (stored.length === 0) {
      return true;
    }
    return stored === AvatarUtils.DEFAULT_AVATAR_STORED ||
      stored === AvatarUtils.DEFAULT_AVATAR_RAW;
  }

  static isCustomAvatar(stored: string): boolean {
    return stored.startsWith('custom_');
  }

  static isSystemPresetStored(stored: string): boolean {
    if (AvatarUtils.isCustomAvatar(stored) || AvatarUtils.isDefaultAvatar(stored)) {
      return false;
    }
    if (stored.indexOf('avatars/img/') === 0) {
      return true;
    }
    return AvatarUtils.indexOfPresetRaw(stored) >= 0;
  }

  static indexOfPresetRaw(rawPath: string): number {
    for (let i = 0; i < AvatarUtils.SYSTEM_PRESET_RAW_PATHS.length; i++) {
      if (AvatarUtils.SYSTEM_PRESET_RAW_PATHS[i] === rawPath) {
        return i;
      }
    }
    return -1;
  }

  /** 将 user.avatar 转为 $rawfile 可用的路径 */
  static resolveRawfilePath(stored: string): string {
    if (AvatarUtils.isDefaultAvatar(stored)) {
      return AvatarUtils.DEFAULT_AVATAR_RAW;
    }
    if (AvatarUtils.isCustomAvatar(stored)) {
      return stored;
    }
    if (stored.indexOf('/') >= 0) {
      return stored;
    }
    if (stored === 'img.png') {
      return AvatarUtils.DEFAULT_AVATAR_RAW;
    }
    return AvatarUtils.DEFAULT_AVATAR_RAW;
  }

  /** 保存到用户资料的头像字段值 */
  static storedFromPresetRaw(rawPath: string): string {
    return rawPath;
  }
}
