import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GlobalStore } from '../model/Models';
import { initAppData } from '../common/AppInit';
import { navigateAfterLogin } from '../common/LoginNav';

@Entry
@Component
struct LoginPage {
  @State account: string = ''
  @State password: string = ''
  @State isPwdShow: boolean = false

  aboutToAppear() {
    initAppData();
  }

  doLogin(): void {
    if (this.account === '' || this.password === '') {
      promptAction.showToast({ message: '请输入账号和密码' });
      return;
    }
    if (GlobalStore.loginByPassword(this.account, this.password)) {
      promptAction.showToast({ message: `欢迎回来，${GlobalStore.getDisplayName()}` });
      navigateAfterLogin();
    } else {
      promptAction.showToast({ message: '账号或密码错误' });
    }
  }

  // 封装跳转方法
  async goPage(url: string) {
    try {
      await router.pushUrl({ url: url });
    } catch (err) {
      console.error("跳转失败：", JSON.stringify(err));
    }
  }

  build() {
    Column() {
      this.StatusBar()
      Column({ space: 40 }) {
        this.LogoArea()
        this.InputArea()
        this.ButtonArea()
        this.OtherLoginArea()
      }
      .width('100%')
      .padding({ left: 30, right: 30, top: 40 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder StatusBar() {
    Row() {
      Row() {
        Text('5G')
          .fontSize(12)
          .fontColor('#333333')
          .margin({ right: 5 })
        Image($r('app.media.ic_signal'))
          .width(18)
          .height(12)
          .margin({ right: 5 })
        Image($r('app.media.ic_wifi'))
          .width(18)
          .height(12)
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Start)

      Text('20:30')
        .fontSize(14)
        .fontColor('#333333')

      Row() {
        Image($r('app.media.ic_battery'))
          .width(25)
          .height(12)
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height(40)
    .padding({ left: 15, right: 15 })
    .backgroundColor('#F5F5F5')
  }

  @Builder LogoArea() {
    Column({ space: 15 }) {
      Image($r('app.media.ic_shop_logo'))
        .width(80)
        .height(80)
        .borderRadius(15)

      Text('登录')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FF5000')

      Text('登录账号以使用更多服务')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder InputArea() {
    Column({ space: 20 }) {
      TextInput({ text: this.account, placeholder: '请输入手机号/会员名' })
        .width('100%')
        .height(50)
        .fontSize(16)
        .placeholderColor('#999999')
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding({ left: 15, right: 15 })
        .onChange((value: string) => {
          this.account = value
        })

      Stack({ alignContent: Alignment.End }) {
        TextInput({ text: this.password, placeholder: '请输入密码' })
          .width('100%')
          .height(50)
          .fontSize(16)
          .placeholderColor('#999999')
          .backgroundColor('#FFFFFF')
          .borderRadius(8)
          .padding({ left: 15, right: 50 })
          .type(this.isPwdShow ? InputType.Normal : InputType.Password)
          .onChange((value: string) => {
            this.password = value
          })

        Image(this.isPwdShow ? $r('app.media.ic_pwd_show') : $r('app.media.ic_pwd_hide'))
          .width(24)
          .height(24)
          .margin({ right: 15 })
          .onClick(() => {
            this.isPwdShow = !this.isPwdShow
          })
      }
      .width('100%')

      Row() {
        Text('短信验证码登录')
          .fontSize(14)
          .fontColor('#FF5000')
          .onClick(() => {
            this.goPage('pages/SmsLogin')
          })

        Text('忘记密码')
          .fontSize(14)
          .fontColor('#FF5000')
          .onClick(() => {
            this.goPage('pages/ForgetPwd')
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ top: 5 })
    }
  }

  @Builder ButtonArea() {
    Column({ space: 20 }) {
      Button('登录')
        .width('100%')
        .height(50)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('#FF5000')
        .borderRadius(25)
        .onClick(() => {
          this.doLogin();
        })

      Text('注册账号')
        .fontSize(14)
        .fontColor('#FF5000')
        .onClick(() => {
          this.goPage('pages/Register')
        })
    }
    .width('100%')
  }

  @Builder OtherLoginArea() {
    Column({ space: 25 }) {
      Row() {
        Divider()
          .layoutWeight(1)
          .strokeWidth(1)
          .color('#EEEEEE')
        Text('其他方式登录')
          .fontSize(12)
          .fontColor('#999999')
          .margin({ left: 15, right: 15 })
        Divider()
          .layoutWeight(1)
          .strokeWidth(1)
          .color('#EEEEEE')
      }
      .width('100%')

      Row({ space: 50 }) {
        Image($r('app.media.ic_wechat'))
          .width(45)
          .height(45)
          .borderRadius(22.5)
        Image($r('app.media.ic_tictok'))
          .width(45)
          .height(45)
          .borderRadius(22.5)
        Image($r('app.media.ic_twitter'))
          .width(45)
          .height(45)
          .borderRadius(22.5)
      }
    }
    .width('100%')
    .margin({ top: 20 })
  }
}