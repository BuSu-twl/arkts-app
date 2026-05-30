import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GlobalStore } from '../model/Models';
import { AppTheme } from '../common/AppTheme';
import { ensureAppData } from '../common/AppInit';
import { AvatarUtils } from '../common/AvatarUtils';
import picker from '@ohos.file.picker';
import fs from '@ohos.file.fs';

@Entry
@Component
struct EditProfilePage {
  @State nickname: string = ''
  @State phone: string = ''
  @State oldPassword: string = ''
  @State newPassword: string = ''
  @State confirmPassword: string = ''
  @State address: string = ''
  @State showPasswordSection: boolean = false
  @State selectedPresetRaw: string = ''
  @State customAvatarPath: string = ''
  private presetAvatarPaths: string[] = AvatarUtils.SYSTEM_PRESET_RAW_PATHS
  @State showPhoneChangeSection: boolean = false
  @State newPhone: string = ''

  aboutToAppear() {
    ensureAppData();
    if (!GlobalStore.isLoggedIn()) {
      promptAction.showToast({ message: '请先登录' });
      router.replaceUrl({ url: 'pages/Login' });
      return;
    }
    if (GlobalStore.currentUser !== null) {
      this.nickname = GlobalStore.currentUser.nickname;
      this.phone = GlobalStore.currentUser.phone;
      this.address = this.getAddressFromUser();
      let avatarName = GlobalStore.currentUser.avatar;
      this.customAvatarPath = '';
      this.selectedPresetRaw = '';
      if (AvatarUtils.isCustomAvatar(avatarName)) {
        this.customAvatarPath = avatarName;
      } else if (AvatarUtils.isSystemPresetStored(avatarName)) {
        this.selectedPresetRaw = GlobalStore.getAvatarRawPath();
      }
    }
  }

  getPreviewRawPath(): string {
    if (this.customAvatarPath.length > 0) {
      return '';
    }
    if (this.selectedPresetRaw.length > 0) {
      return this.selectedPresetRaw;
    }
    return AvatarUtils.DEFAULT_AVATAR_RAW;
  }

  getAddressFromUser(): string {
    return '';
  }

  changePhone() {
    if (this.newPhone.length !== 11) {
      promptAction.showToast({ message: '请输入正确的11位手机号' });
      return;
    }

    if (this.newPhone === this.phone) {
      promptAction.showToast({ message: '新手机号不能与原手机号相同' });
      return;
    }

    if (!GlobalStore.updateUserPhone(this.newPhone)) {
      promptAction.showToast({ message: '该手机号已被其他账号使用' });
      return;
    }

    this.phone = this.newPhone;
    this.newPhone = '';
    this.showPhoneChangeSection = false;
    promptAction.showToast({ message: '手机号修改成功' });
  }

  async selectCustomAvatar() {
    try {
      let photoSelectOptions = new picker.PhotoSelectOptions();
      photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;

      let photoPicker = new picker.PhotoViewPicker();
      let photoSelectResult = await photoPicker.select(photoSelectOptions);

      if (photoSelectResult && photoSelectResult.photoUris && photoSelectResult.photoUris.length > 0) {
        let selectedUri = photoSelectResult.photoUris[0];

        let context = getContext(this);
        let filesDir = context.filesDir;
        let fileName = `custom_${Date.now()}.png`;
        let destPath = `${filesDir}/${fileName}`;

        let file = fs.openSync(selectedUri, fs.OpenMode.READ_ONLY);
        let stat = fs.statSync(selectedUri);
        let buffer = new ArrayBuffer(stat.size);
        fs.readSync(file.fd, buffer);
        fs.closeSync(file);

        let destFile = fs.openSync(destPath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
        fs.writeSync(destFile.fd, buffer);
        fs.closeSync(destFile);

        this.customAvatarPath = fileName;
        this.selectedPresetRaw = '';

        promptAction.showToast({ message: '头像已选择' });
      }
    } catch (error) {
      console.error('选择头像失败:', error);
      promptAction.showToast({ message: '选择头像失败' });
    }
  }

  saveProfile() {
    if (this.nickname.trim().length === 0) {
      promptAction.showToast({ message: '昵称不能为空' });
      return;
    }

    if (GlobalStore.currentUser !== null) {
      GlobalStore.currentUser.nickname = this.nickname;

      if (this.customAvatarPath.length > 0) {
        GlobalStore.currentUser.avatar = this.customAvatarPath;
      } else if (this.selectedPresetRaw.length > 0) {
        GlobalStore.currentUser.avatar = AvatarUtils.storedFromPresetRaw(this.selectedPresetRaw);
      } else {
        GlobalStore.currentUser.avatar = AvatarUtils.DEFAULT_AVATAR_STORED;
      }

      let user = GlobalStore.findUserById(GlobalStore.currentUser.id);
      if (user !== null) {
        user.nickname = this.nickname;
        user.avatar = GlobalStore.currentUser.avatar;
      }

      GlobalStore.persistUsersToDisk();
      promptAction.showToast({ message: '保存成功' });
      router.back();
    }
  }

  changePassword() {
    if (this.oldPassword.length === 0) {
      promptAction.showToast({ message: '请输入原密码' });
      return;
    }

    if (GlobalStore.currentUser === null) {
      promptAction.showToast({ message: '用户未登录' });
      return;
    }

    if (this.oldPassword !== GlobalStore.currentUser.password) {
      promptAction.showToast({ message: '原密码错误' });
      return;
    }

    if (this.newPassword.length < 6) {
      promptAction.showToast({ message: '新密码长度不能少于6位' });
      return;
    }

    if (this.newPassword !== this.confirmPassword) {
      promptAction.showToast({ message: '两次输入的新密码不一致' });
      return;
    }

    GlobalStore.currentUser.password = this.newPassword;
    let user = GlobalStore.findUserById(GlobalStore.currentUser.id);
    if (user !== null) {
      user.password = this.newPassword;
    }

    this.oldPassword = '';
    this.newPassword = '';
    this.confirmPassword = '';
    this.showPasswordSection = false;

    GlobalStore.persistUsersToDisk();
    promptAction.showToast({ message: '密码修改成功' });
  }

  saveAddress() {
    if (this.address.trim().length === 0) {
      promptAction.showToast({ message: '收货地址不能为空' });
      return;
    }

    promptAction.showToast({ message: '地址保存成功' });
  }

  selectPresetAvatar(rawPath: string) {
    this.selectedPresetRaw = rawPath;
    this.customAvatarPath = '';
  }

  build() {
    Column() {
      Row() {
        Text('返回')
          .fontSize(16)
          .fontColor('#FF5000')
          .onClick(() => {
            router.back();
          })

        Text('编辑资料')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Text('保存')
          .fontSize(16)
          .fontColor('#FF5000')
          .onClick(() => {
            this.saveProfile();
          })
      }
      .width('100%')
      .height(50)
      .padding({ left: 15, right: 15 })
      .backgroundColor('#FFFFFF')

      Scroll() {
        Column({ space: 15 }) {
          Column({ space: 10 }) {
            Text('头像')
              .fontSize(16)
              .fontColor('#333333')
              .width('100%')
              .padding({ left: 15 })

            Row() {
              if (this.customAvatarPath.length > 0) {
                Image(`file://${getContext(this).filesDir}/${this.customAvatarPath}`)
                  .width(80)
                  .height(80)
                  .borderRadius(40)
                  .objectFit(ImageFit.Cover)
              } else {
                Image($rawfile(this.getPreviewRawPath()))
                  .width(80)
                  .height(80)
                  .borderRadius(40)
                  .objectFit(ImageFit.Cover)
              }
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .padding({ top: 10, bottom: 10 })

            Button('上传自定义头像')
              .width('90%')
              .height(45)
              .fontSize(16)
              .backgroundColor('#4CAF50')
              .borderRadius(8)
              .onClick(() => {
                this.selectCustomAvatar();
              })

            Text('或选择预设头像')
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 10 })

            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(this.presetAvatarPaths, (rawPath: string) => {
                Column() {
                  Image($rawfile(rawPath))
                    .width(60)
                    .height(60)
                    .borderRadius(30)
                    .objectFit(ImageFit.Cover)
                }
                .width('30%')
                .margin({ bottom: 12 })
                .border({
                  width: (this.selectedPresetRaw === rawPath && this.customAvatarPath.length === 0) ? 3 : 0,
                  color: AppTheme.PRIMARY
                })
                .borderRadius(30)
                .onClick(() => {
                  this.selectPresetAvatar(rawPath);
                })
              }, (rawPath: string) => rawPath)
            }
            .width('100%')
            .padding({ left: 15, right: 15 })
          }
          .width('100%')
          .padding({ top: 15, bottom: 15 })
          .backgroundColor('#FFFFFF')

          Column({ space: 10 }) {
            Text('昵称')
              .fontSize(16)
              .fontColor('#333333')
              .width('100%')
              .padding({ left: 15 })

            TextInput({ text: this.nickname, placeholder: '请输入昵称' })
              .width('90%')
              .height(50)
              .fontSize(16)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .padding({ left: 15, right: 15 })
              .onChange((value: string) => {
                this.nickname = value;
              })
          }
          .width('100%')
          .padding({ top: 15, bottom: 15 })
          .backgroundColor('#FFFFFF')

          Column({ space: 10 }) {
            Row() {
              Text('手机号')
                .fontSize(16)
                .fontColor('#333333')
                .layoutWeight(1)

              Text(this.showPhoneChangeSection ? '收起' : '修改')
                .fontSize(14)
                .fontColor('#FF5000')
                .onClick(() => {
                  this.showPhoneChangeSection = !this.showPhoneChangeSection;
                  if (!this.showPhoneChangeSection) {
                    this.newPhone = '';
                  }
                })
            }
            .width('90%')
            .padding({ left: 15, right: 15 })

            Text(this.phone)
              .fontSize(16)
              .fontColor('#999999')
              .width('90%')
              .padding({ left: 15 })

            if (this.showPhoneChangeSection) {
              Column({ space: 10 }) {
                Text('修改后请使用新手机号登录')
                  .fontSize(12)
                  .fontColor(AppTheme.TEXT_HINT)
                  .width('100%')

                TextInput({ text: this.newPhone, placeholder: '请输入新手机号' })
                  .width('100%')
                  .height(50)
                  .fontSize(16)
                  .type(InputType.Number)
                  .backgroundColor(AppTheme.BG_MUTED)
                  .borderRadius(8)
                  .padding({ left: 15, right: 15 })
                  .maxLength(11)
                  .onChange((value: string) => {
                    this.newPhone = value;
                  })

                Button('确认修改手机号')
                  .width('100%')
                  .height(45)
                  .fontSize(16)
                  .backgroundColor(AppTheme.PRIMARY)
                  .borderRadius(8)
                  .margin({ top: 10 })
                  .onClick(() => {
                    this.changePhone();
                  })
              }
              .width('90%')
              .padding({ left: 15, right: 15 })
            }
          }
          .width('100%')
          .padding({ top: 15, bottom: 15 })
          .backgroundColor('#FFFFFF')

          Column({ space: 10 }) {
            Row() {
              Text('密码')
                .fontSize(16)
                .fontColor('#333333')
                .layoutWeight(1)

              Text(this.showPasswordSection ? '收起' : '修改')
                .fontSize(14)
                .fontColor('#FF5000')
                .onClick(() => {
                  this.showPasswordSection = !this.showPasswordSection;
                })
            }
            .width('90%')
            .padding({ left: 15, right: 15 })

            if (this.showPasswordSection) {
              Column({ space: 10 }) {
                TextInput({ text: this.oldPassword, placeholder: '请输入原密码' })
                  .width('100%')
                  .height(50)
                  .fontSize(16)
                  .type(InputType.Password)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                  .padding({ left: 15, right: 15 })
                  .onChange((value: string) => {
                    this.oldPassword = value;
                  })

                TextInput({ text: this.newPassword, placeholder: '请输入新密码（至少6位）' })
                  .width('100%')
                  .height(50)
                  .fontSize(16)
                  .type(InputType.Password)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                  .padding({ left: 15, right: 15 })
                  .onChange((value: string) => {
                    this.newPassword = value;
                  })

                TextInput({ text: this.confirmPassword, placeholder: '请确认新密码' })
                  .width('100%')
                  .height(50)
                  .fontSize(16)
                  .type(InputType.Password)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                  .padding({ left: 15, right: 15 })
                  .onChange((value: string) => {
                    this.confirmPassword = value;
                  })

                Button('确认修改密码')
                  .width('100%')
                  .height(45)
                  .fontSize(16)
                  .backgroundColor('#FF5000')
                  .borderRadius(8)
                  .margin({ top: 10 })
                  .onClick(() => {
                    this.changePassword();
                  })
              }
              .width('90%')
              .padding({ left: 15, right: 15 })
            }
          }
          .width('100%')
          .padding({ top: 15, bottom: 15 })
          .backgroundColor('#FFFFFF')

          Column({ space: 10 }) {
            Text('收货地址')
              .fontSize(16)
              .fontColor('#333333')
              .width('100%')
              .padding({ left: 15 })

            TextArea({ text: this.address, placeholder: '请输入详细收货地址' })
              .width('90%')
              .height(100)
              .fontSize(16)
              .backgroundColor('#F5F5F5')
              .borderRadius(8)
              .padding({ left: 15, right: 15, top: 10, bottom: 10 })
              .onChange((value: string) => {
                this.address = value;
              })

            Button('保存地址')
              .width('90%')
              .height(45)
              .fontSize(16)
              .backgroundColor('#FF5000')
              .borderRadius(8)
              .onClick(() => {
                this.saveAddress();
              })
          }
          .width('100%')
          .padding({ top: 15, bottom: 15 })
          .backgroundColor('#FFFFFF')
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

}
