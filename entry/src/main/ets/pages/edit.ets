import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GlobalStore } from '../model/Models';

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

  aboutToAppear() {
    if (GlobalStore.currentUser !== null) {
      this.nickname = GlobalStore.currentUser.nickname;
      this.phone = GlobalStore.currentUser.phone;
      this.address = this.getAddressFromUser();
      let avatarName = GlobalStore.currentUser.avatar;
      if (avatarName.length > 0) {
        let num = parseInt(avatarName.replace('.png', ''));
        if (!isNaN(num)) {
          this.avatarIndex = num;
        }
      }
    }
  }

  getAddressFromUser(): string {
    // 这里可以从用户信息中获取地址，如果 User 接口有 address 字段
    // 目前先返回空字符串或默认值
    return '';
  }

  saveProfile() {
    if (this.nickname.trim().length === 0) {
      promptAction.showToast({ message: '昵称不能为空' });
      return;
    }

    if (GlobalStore.currentUser !== null) {
      GlobalStore.currentUser.nickname = this.nickname;
      GlobalStore.currentUser.avatar = `${this.avatarIndex}.png`;

      // 同步到 allUsers 中
      let user = GlobalStore.findUserById(GlobalStore.currentUser.id);
      if (user !== null) {
        user.nickname = this.nickname;
        user.avatar = `${this.avatarIndex}.png`;
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
    // 这里可以添加保存地址的逻辑
  }

  selectAvatar(index: number) {
    this.avatarIndex = index;
  }

  build() {
    Column() {
      // 标题栏
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
          // 头像选择区域
          Column({ space: 10 }) {
            Text('头像')
              .fontSize(16)
              .fontColor('#333333')
              .width('100%')
              .padding({ left: 15 })

            Row({ space: 15 }) {
              ForEach([1, 2, 3, 4, 5, 6], (index: number) => {
                Image($r(`app.media.${index}`))
                  .width(60)
                  .height(60)
                  .borderRadius(30)
                  .border({
                    width: this.avatarIndex === index ? 3 : 0,
                    color: '#FF5000'
                  })
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

          // 昵称编辑
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

          // 手机号显示（只读）
          Column({ space: 10 }) {
            Text('手机号')
              .fontSize(16)
              .fontColor('#333333')
              .width('100%')
              .padding({ left: 15 })

            Text(this.phone)
              .fontSize(16)
              .fontColor('#999999')
              .width('90%')
              .padding({ left: 15 })
          }
          .width('100%')
          .padding({ top: 15, bottom: 15 })
          .backgroundColor('#FFFFFF')

          // 密码修改
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

          // 收货地址
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
