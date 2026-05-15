import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GlobalStore } from '../model/Models';
import { BottomNavBar } from '../components/BottomNavBar';

@Entry
@Component
struct ProfilePage {
  @State isLoggedIn: boolean = false;
  @State nickname: string = '商城用户';
  @State phone: string = '未登录';
  @State memberName: string = '';
  @State avatarPath: string = '';

  aboutToAppear() {
    this.refreshUserInfo();
  }

  onPageShow() {
    this.refreshUserInfo();
  }

  refreshUserInfo() {
    this.isLoggedIn = GlobalStore.isLoggedIn();
    this.nickname = GlobalStore.getDisplayName();
    this.phone = GlobalStore.getDisplayPhone();
    if (GlobalStore.currentUser !== null) {
      this.memberName = GlobalStore.currentUser.memberName;
      this.avatarPath = GlobalStore.getAvatarRawPath();
    } else {
      this.memberName = '';
      this.avatarPath = '';
    }
  }

  doLogout() {
    GlobalStore.logout();
    this.refreshUserInfo();
    promptAction.showToast({ message: '已退出登录' });
  }

  @Builder
  menuRow(title: string, onTap: () => void) {
    Row() {
      Text(title)
        .fontSize(15)
        .fontColor('#333333')
      Blank()
      Text('>')
        .fontSize(14)
        .fontColor('#CCCCCC')
    }
    .width('100%')
    .height(52)
    .padding({ left: 16, right: 16 })
    .backgroundColor(Color.White)
    .onClick(onTap)
  }

  build() {
    Column() {
      Column({ space: 8 }) {
        if (this.isLoggedIn && this.avatarPath.length > 0) {
          Image($rawfile(this.avatarPath))
            .width(64)
            .height(64)
            .borderRadius(32)
            .objectFit(ImageFit.Cover)
            .backgroundColor('#EEEEEE')
        } else {
          Circle({ width: 64, height: 64 })
            .fill('#E60012')
        }
        Text(this.nickname)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        if (this.isLoggedIn) {
          Text(`手机：${this.phone}`)
            .fontSize(13)
            .fontColor('#666666')
          Text(`会员名：${this.memberName}`)
            .fontSize(12)
            .fontColor('#999999')
        } else {
          Text('登录后同步优惠券与订单信息')
            .fontSize(13)
            .fontColor('#999999')
        }
      }
      .width('100%')
      .padding({ top: 40, bottom: 24 })
      .backgroundColor(Color.White)

      Column({ space: 1 }) {
        this.menuRow('我的订单', () => {
          if (!GlobalStore.isLoggedIn()) {
            promptAction.showToast({ message: '请先登录' });
            router.pushUrl({ url: 'pages/Login' });
            return;
          }
          router.pushUrl({ url: 'pages/OrderListPage' });
        })
        this.menuRow('我的收藏', () => {
          router.pushUrl({ url: 'pages/FavoritePage' });
        })
        this.menuRow('购物车', () => {
          router.pushUrl({ url: 'pages/CartPage' });
        })
        if (this.isLoggedIn) {
          this.menuRow('退出登录', () => {
            this.doLogout();
          })
        } else {
          this.menuRow('账号登录', () => {
            router.pushUrl({ url: 'pages/Login' });
          })
        }
      }
      .width('100%')
      .margin({ top: 12 })

      Blank()

      BottomNavBar({ currentIndex: 2 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
