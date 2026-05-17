import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GlobalStore } from '../model/Models';
import { initAppData } from '../common/AppInit';
import { navigateAfterLogin } from '../common/LoginNav';
import { AppTheme } from '../common/AppTheme';

@Entry
@Component
struct SmsLogin {
  @State phone: string = '';
  @State code: string = '';
  @State countDown: number = 0;
  @State btnEnable: boolean = true;

  aboutToAppear() {
    initAppData();
  }

  startCountDown(): void {
    this.countDown = 60;
    this.btnEnable = false;
    const timer: number = setInterval((): void => {
      this.countDown--;
      if (this.countDown <= 0) {
        clearInterval(timer);
        this.btnEnable = true;
      }
    }, 1000);
  }

  getCode(): void {
    if (this.phone.length !== 11) {
      try {
        promptAction.showToast({ message: '请输入正确手机号' });
      } catch (e) {}
      return;
    }
    this.startCountDown();
    try {
      promptAction.showToast({ message: '验证码已发送' });
    } catch (e) {}
  }

  doLogin(): void {
    if (!this.phone) {
      try {
        promptAction.showToast({ message: '请输入手机号' });
      } catch (e) {}
      return;
    }
    if (!this.code) {
      try {
        promptAction.showToast({ message: '请输入验证码' });
      } catch (e) {}
      return;
    }
    if (GlobalStore.loginBySms(this.phone, this.code)) {
      promptAction.showToast({ message: `欢迎回来，${GlobalStore.getDisplayName()}` });
      navigateAfterLogin();
    } else {
      promptAction.showToast({ message: '手机号或验证码错误' });
    }
  }

  build() {
    Column() {
      Row() {
        Text('← 返回')
          .fontSize(16)
          .onClick(() => {
            try {
              router.back();
            } catch (e) {}
          });
        Text('短信验证码登录')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize(18)
          .fontWeight(FontWeight.Medium);
      }
      .width('100%')
      .padding(15);

      Column({ space: 20 }) {
        TextInput({ text: this.phone, placeholder: '请输入手机号' })
          .width('100%')
          .height(50)
          .backgroundColor(AppTheme.WHITE)
          .borderRadius(8)
          .padding({ left: 15 })
          .onChange((v: string) => { this.phone = v; });

        Row({ space: 10 }) {
          TextInput({ text: this.code, placeholder: '请输入短信验证码' })
            .layoutWeight(1)
            .height(50)
            .backgroundColor(AppTheme.WHITE)
            .borderRadius(8)
            .padding({ left: 15 })
            .onChange((v: string) => { this.code = v; });

          Button(this.btnEnable ? '获取验证码' : `${this.countDown}s`)
            .width(110)
            .height(50)
            .backgroundColor(this.btnEnable ? AppTheme.PRIMARY : AppTheme.BTN_DISABLED)
            .borderRadius(8)
            .enabled(this.btnEnable)
            .onClick(() => { this.getCode(); });
        }
        .width('100%');

        Button('登录')
          .width('100%')
          .height(50)
          .backgroundColor(AppTheme.PRIMARY)
          .borderRadius(25)
          .onClick(() => { this.doLogin(); });
      }
      .padding({ left: 30, right: 30, top: 30 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG_PAGE);
  }
}