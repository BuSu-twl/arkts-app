import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GlobalStore } from '../model/Models';
import { AppTheme } from '../common/AppTheme';
import { ensureAppData } from '../common/AppInit';
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
  @State avatarIndex: number = 0
  @State customAvatarPath: string = ''
  @State showPhoneChangeSection: boolean = false
  @State newPhone: string = ''
  @State phoneVerifyCode: string = ''
  @State phoneCountDown: number = 0
  @State phoneBtnEnable: boolean = true

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
      if (avatarName.length > 0) {
        if (avatarName.startsWith('custom_')) {
          this.customAvatarPath = avatarName;
          this.avatarIndex = 0;
        } else {
          let num = parseInt(avatarName.replace('.png', ''));
          if (!isNaN(num)) {
            this.avatarIndex = num;
          }
        }
      }
    }
  }

  getAddressFromUser(): string {
    return '';
  }

  startPhoneCountDown(): void {
    this.phoneCountDown = 60;
    this.phoneBtnEnable = false;
    const timer: number = setInterval((): void => {
      this.phoneCountDown--;
      if (this.phoneCountDown <= 0) {
        clearInterval(timer);
        this.phoneBtnEnable = true;
      }
    }, 1000);
  }

  sendPhoneVerifyCode(): void {
    if (this.newPhone.length !== 11) {
      promptAction.showToast({ message: '请输入正确的11位手机号' });
      return;
    }

    if (this.newPhone === this.phone) {
      promptAction.showToast({ message: '新手机号不能与原手机号相同' });
      return;
    }

    this.startPhoneCountDown();
    promptAction.showToast({ message: '验证码已发送到新手机号' });
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

    if (this.phoneVerifyCode.length === 0) {
      promptAction.showToast({ message: '请输入验证码' });
      return;
    }

    if (GlobalStore.currentUser === null) {
      promptAction.showToast({ message: '用户未登录' });
      return;
    }

    GlobalStore.currentUser.phone = this.newPhone;
    GlobalStore.currentUser.account = this.newPhone;

    let user = GlobalStore.findUserById(GlobalStore.currentUser.id);
    if (user !== null) {
      user.phone = this.newPhone;
      user.account = this.newPhone;
    }

    this.phone = this.newPhone;
    this.newPhone = '';
    this.phoneVerifyCode = '';
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
        this.avatarIndex = 0;

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
      } else {
        GlobalStore.currentUser.avatar = `${this.avatarIndex}.png`;
      }

      let user = GlobalStore.findUserById(GlobalStore.currentUser.id);
      if (user !== null) {
        user.nickname = this.nickname;
        if (this.customAvatarPath.length > 0) {
          user.avatar = this.customAvatarPath;
        } else {
          user.avatar = `${this.avatarIndex}.png`;
        }
      }

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

    promptAction.showToast({ message: '密码修改成功' });
  }

  saveAddress() {
    if (this.address.trim().length === 0) {
      promptAction.showToast({ message: '收货地址不能为空' });
      return;
    }

    promptAction.showToast({ message: '地址保存成功' });
  }

  selectAvatar(index: number) {
    this.avatarIndex = index;
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
                this.PresetAvatarImage(this.avatarIndex > 0 ? this.avatarIndex : 1, 80)
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

            Row({ space: 15 }) {
              ForEach([1, 2, 3, 4, 5, 6], (index: number) => {
                Column() {
                  this.PresetAvatarImage(index, 60)
                }
                .border({
                  width: (this.avatarIndex === index && this.customAvatarPath.length === 0) ? 3 : 0,
                  color: AppTheme.PRIMARY
                })
                .borderRadius(30)
                .onClick(() => {
                  this.selectAvatar(index);
                })
              }, (index: number) => index.toString())
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
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
                    this.phoneVerifyCode = '';
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
                TextInput({ text: this.newPhone, placeholder: '请输入新手机号' })
                  .width('100%')
                  .height(50)
                  .fontSize(16)
                  .type(InputType.Number)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(8)
                  .padding({ left: 15, right: 15 })
                  .onChange((value: string) => {
                    this.newPhone = value;
                  })

                Row({ space: 10 }) {
                  TextInput({ text: this.phoneVerifyCode, placeholder: '请输入验证码' })
                    .layoutWeight(1)
                    .height(50)
                    .fontSize(16)
                    .type(InputType.Number)
                    .backgroundColor('#F5F5F5')
                    .borderRadius(8)
                    .padding({ left: 15, right: 15 })
                    .onChange((value: string) => {
                      this.phoneVerifyCode = value;
                    })

                  Button(this.phoneBtnEnable ? '获取验证码' : `${this.phoneCountDown}s`)
                    .width(120)
                    .height(50)
                    .fontSize(14)
                    .backgroundColor(this.phoneBtnEnable ? '#FF5000' : '#CCCCCC')
                    .borderRadius(8)
                    .enabled(this.phoneBtnEnable)
                    .onClick(() => {
                      this.sendPhoneVerifyCode();
                    })
                }
                .width('100%')

                Button('确认修改手机号')
                  .width('100%')
                  .height(45)
                  .fontSize(16)
                  .backgroundColor('#FF5000')
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

  @Builder
  PresetAvatarImage(index: number, size: number) {
    if (index === 1) {
      Image($rawfile('1.png')).width(size).height(size).borderRadius(size / 2).objectFit(ImageFit.Cover)
    } else if (index === 2) {
      Image($rawfile('2.png')).width(size).height(size).borderRadius(size / 2).objectFit(ImageFit.Cover)
    } else if (index === 3) {
      Image($rawfile('3.png')).width(size).height(size).borderRadius(size / 2).objectFit(ImageFit.Cover)
    } else if (index === 4) {
      Image($rawfile('4.png')).width(size).height(size).borderRadius(size / 2).objectFit(ImageFit.Cover)
    } else if (index === 5) {
      Image($rawfile('5.png')).width(size).height(size).borderRadius(size / 2).objectFit(ImageFit.Cover)
    } else {
      Image($rawfile('6.png')).width(size).height(size).borderRadius(size / 2).objectFit(ImageFit.Cover)
    }
  }
}
