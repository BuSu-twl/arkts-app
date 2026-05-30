import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GlobalStore } from '../model/Models';
import { ensureAppData } from '../common/AppInit';
import { AppTheme } from '../common/AppTheme';

@Entry
@Component
struct ForgetPwd {
  @State phone: string = '';
  @State newPwd: string = '';
  @State confirmPwd: string = '';

  aboutToAppear() {
    ensureAppData();
  }

  resetPwd(): void {
    if (!this.phone) {
      promptAction.showToast({ message: '请输入手机号' });
      return;
    }
    if (this.phone.length !== 11) {
      promptAction.showToast({ message: '请输入11位有效手机号' });
      return;
    }
    if (!this.newPwd) {
      promptAction.showToast({ message: '请设置新密码' });
      return;
    }
    if (this.newPwd.length < 6) {
      promptAction.showToast({ message: '密码至少6位' });
      return;
    }
    if (this.newPwd !== this.confirmPwd) {
      promptAction.showToast({ message: '两次密码不一致' });
      return;
    }
    if (GlobalStore.resetPassword(this.phone, this.newPwd)) {
      promptAction.showToast({ message: '密码重置成功，请重新登录' });
      router.back();
    } else {
      promptAction.showToast({ message: '该手机号未注册' });
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
        Text('忘记密码')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .fontSize(18)
          .fontWeight(FontWeight.Medium);
      }
      .width('100%')
      .padding(15);

      Column({ space: 20 }) {
        Text('验证已注册手机号后可直接设置新密码')
          .fontSize(13)
          .fontColor(AppTheme.TEXT_HINT)
          .width('100%')

        TextInput({ text: this.phone, placeholder: '请输入注册手机号' })
          .width('100%')
          .height(50)
          .backgroundColor(AppTheme.WHITE)
          .borderRadius(8)
          .padding({ left: 15 })
          .maxLength(11)
          .type(InputType.PhoneNumber)
          .onChange((v: string) => { this.phone = v; });

        TextInput({ text: this.newPwd, placeholder: '请设置新密码（至少6位）' })
          .width('100%')
          .height(50)
          .backgroundColor(AppTheme.WHITE)
          .borderRadius(8)
          .padding({ left: 15 })
          .type(InputType.Password)
          .onChange((v: string) => { this.newPwd = v; });

        TextInput({ text: this.confirmPwd, placeholder: '请再次确认密码' })
          .width('100%')
          .height(50)
          .backgroundColor(AppTheme.WHITE)
          .borderRadius(8)
          .padding({ left: 15 })
          .type(InputType.Password)
          .onChange((v: string) => { this.confirmPwd = v; });

        Button('重置密码')
          .width('100%')
          .height(50)
          .backgroundColor(AppTheme.PRIMARY)
          .borderRadius(25)
          .onClick(() => { this.resetPwd(); });
      }
      .padding({ left: 30, right: 30, top: 30 });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG_PAGE);
  }
}
