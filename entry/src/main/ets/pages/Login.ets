import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GlobalStore } from '../model/Models';
import { ensureAppData } from '../common/AppInit';
import { navigateAfterLogin } from '../common/LoginNav';
import { AppTheme } from '../common/AppTheme';

@Entry
@Component
struct LoginPage {
  @State account: string = ''
  @State password: string = ''
  @State isPwdShow: boolean = false

  aboutToAppear() {
    ensureAppData();
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

  async goPage(url: string) {
    try {
      await router.pushUrl({ url: url });
    } catch (err) {
      console.error('跳转失败：', JSON.stringify(err));
    }
  }

  build() {
    Column({ space: 40 }) {
      this.LogoArea()
      this.InputArea()
      this.ButtonArea()
    }
    .width('100%')
    .height('100%')
    .padding({ left: 30, right: 30, top: 60 })
    .backgroundColor(AppTheme.BG_PAGE)
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
        .fontColor(AppTheme.PRIMARY)

      Text('登录账号以使用更多服务')
        .fontSize(14)
        .fontColor(AppTheme.TEXT_HINT)
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
        .placeholderColor(AppTheme.TEXT_HINT)
        .backgroundColor(AppTheme.WHITE)
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
          .placeholderColor(AppTheme.TEXT_HINT)
          .backgroundColor(AppTheme.WHITE)
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
        Blank()
        Text('忘记密码')
          .fontSize(14)
          .fontColor(AppTheme.PRIMARY)
          .onClick(() => {
            this.goPage('pages/ForgetPwd')
          })
      }
      .width('100%')
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
        .backgroundColor(AppTheme.PRIMARY)
        .borderRadius(25)
        .onClick(() => {
          this.doLogin();
        })

      Text('注册账号')
        .fontSize(14)
        .fontColor(AppTheme.PRIMARY)
        .onClick(() => {
          this.goPage('pages/Register')
        })
    }
    .width('100%')
  }
}
