import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GlobalStore } from '../model/Models';
import { ensureAppData } from '../common/AppInit';
import { navigateAfterLogin } from '../common/LoginNav';
import { AppTheme } from '../common/AppTheme';

@Entry
@Component
struct Register {
  @State phone: string = '';
  @State code: string = '';
  @State pwd: string = '';
  @State confirmPwd: string = '';
  @State isPwdShow: boolean = false;
  @State generatedCode: string = '';
  @State hasCaptcha: boolean = false;
  @State countDown: number = 0;
  @State btnEnable: boolean = true;

  aboutToAppear() {
    ensureAppData();
    this.issueCaptcha(false);
  }

  generateRandomCode(): string {
    let result = '';
    for (let i = 0; i < 6; i++) {
      result += `${Math.floor(Math.random() * 10)}`;
    }
    return result;
  }

  trimPhone(): string {
    let digits = '';
    for (let i = 0; i < this.phone.length; i++) {
      let c = this.phone.charAt(i);
      if (c >= '0' && c <= '9') {
        digits += c;
      }
    }
    return digits;
  }

  isPhoneValid(phone: string): boolean {
    return phone.length === 11 && phone.charAt(0) === '1';
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

  issueCaptcha(showToast: boolean): void {
    this.generatedCode = this.generateRandomCode();
    this.hasCaptcha = true;
    this.code = '';
    if (showToast) {
      promptAction.showToast({ message: '图形验证码已刷新' });
    }
  }

  refreshCaptcha(): void {
    this.issueCaptcha(true);
    this.startCountDown();
  }

  doRegister(): void {
    let phoneNum = this.trimPhone();
    this.phone = phoneNum;

    if (!this.isPhoneValid(phoneNum)) {
      promptAction.showToast({ message: '请输入11位有效手机号' });
      return;
    }
    if (!this.hasCaptcha || this.generatedCode.length === 0) {
      this.issueCaptcha(false);
    }
    if (this.code.length === 0) {
      promptAction.showToast({ message: '请输入图形验证码' });
      return;
    }
    if (this.code !== this.generatedCode) {
      promptAction.showToast({ message: '图形验证码错误，请重新输入' });
      this.issueCaptcha(true);
      return;
    }
    if (this.pwd.length < 6) {
      promptAction.showToast({ message: '密码至少6位' });
      return;
    }
    if (this.pwd !== this.confirmPwd) {
      promptAction.showToast({ message: '两次输入的密码不一致' });
      return;
    }
    if (GlobalStore.findUserByPhone(phoneNum) !== null) {
      promptAction.showToast({ message: '该手机号已注册，请直接登录' });
      return;
    }

    let user = GlobalStore.registerUser(phoneNum, this.pwd);
    if (user === null) {
      promptAction.showToast({ message: '注册失败，请检查信息后重试' });
      return;
    }

    promptAction.showToast({ message: `注册成功，欢迎 ${GlobalStore.getDisplayName()}` });
    try {
      navigateAfterLogin();
    } catch (e) {
      router.replaceUrl({ url: 'pages/HomePage' });
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
            } catch (e) {
              router.replaceUrl({ url: 'pages/Login' });
            }
          });
        Text('账号注册')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize(18)
          .fontWeight(FontWeight.Medium);
      }
      .width('100%')
      .padding(15);

      Scroll() {
        Column({ space: 20 }) {
          TextInput({ text: this.phone, placeholder: '请输入11位手机号' })
            .width('100%')
            .height(50)
            .backgroundColor(AppTheme.WHITE)
            .borderRadius(8)
            .padding({ left: 15, right: 15 })
            .maxLength(11)
            .type(InputType.PhoneNumber)
            .onChange((v: string) => {
              this.phone = v;
            });

          Column({ space: 8 }) {
            Text('请输入下方图形验证码（仅数字）')
              .fontSize(12)
              .fontColor(AppTheme.TEXT_HINT)
              .width('100%')

            Row({ space: 10 }) {
              Column() {
                Text(this.hasCaptcha ? this.generatedCode : '------')
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppTheme.PRIMARY)
                  .letterSpacing(8)
              }
              .layoutWeight(1)
              .height(52)
              .justifyContent(FlexAlign.Center)
              .backgroundColor(AppTheme.PRIMARY_SOFT)
              .borderRadius(8)
              .border({ width: 1, color: AppTheme.PRIMARY_BORDER })

              Button(this.btnEnable ? '换一张' : `${this.countDown}s`)
                .width(96)
                .height(52)
                .fontSize(14)
                .backgroundColor(this.btnEnable ? AppTheme.PRIMARY : AppTheme.BTN_DISABLED)
                .borderRadius(8)
                .enabled(this.btnEnable)
                .onClick(() => {
                  this.refreshCaptcha();
                });
            }
            .width('100%')

            TextInput({ text: this.code, placeholder: '请输入图形验证码' })
              .width('100%')
              .height(50)
              .backgroundColor(AppTheme.WHITE)
              .borderRadius(8)
              .padding({ left: 15, right: 15 })
              .maxLength(6)
              .type(InputType.Number)
              .onChange((v: string) => {
                this.code = v;
              });
          }
          .width('100%')

          Stack({ alignContent: Alignment.End }) {
            TextInput({ text: this.pwd, placeholder: '请设置登录密码（至少6位）' })
              .width('100%')
              .height(50)
              .backgroundColor(AppTheme.WHITE)
              .borderRadius(8)
              .padding({ left: 15, right: 50 })
              .type(this.isPwdShow ? InputType.Normal : InputType.Password)
              .onChange((v: string) => {
                this.pwd = v;
              });

            Image(this.isPwdShow ? $r('app.media.ic_pwd_show') : $r('app.media.ic_pwd_hide'))
              .width(24)
              .height(24)
              .margin({ right: 15 })
              .onClick(() => {
                this.isPwdShow = !this.isPwdShow;
              });
          }
          .width('100%')

          TextInput({ text: this.confirmPwd, placeholder: '请再次输入密码' })
            .width('100%')
            .height(50)
            .backgroundColor(AppTheme.WHITE)
            .borderRadius(8)
            .padding({ left: 15, right: 15 })
            .type(this.isPwdShow ? InputType.Normal : InputType.Password)
            .onChange((v: string) => {
              this.confirmPwd = v;
            });

          Button('注册')
            .width('100%')
            .height(50)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .backgroundColor(AppTheme.PRIMARY)
            .borderRadius(25)
            .onClick(() => {
              this.doRegister();
            });

          Text('已有账号？去登录')
            .fontSize(14)
            .fontColor(AppTheme.PRIMARY)
            .onClick(() => {
              router.replaceUrl({ url: 'pages/Login' });
            });
        }
        .padding({ left: 30, right: 30, top: 20, bottom: 30 });
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG_PAGE);
  }
}
