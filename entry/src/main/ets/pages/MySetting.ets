import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GlobalStore } from '../model/Models';
import { BottomNavBar } from '../components/BottomNavBar';
import { AppTheme } from '../common/AppTheme';
import { ensureAppData } from '../common/AppInit';
import { AvatarUtils } from '../common/AvatarUtils';

/** 个人中心（底部 Tab） */
@Entry
@Component
struct MySetting {
  @State displayName: string = '商城用户';
  @State displayAccount: string = '未登录';
  @State balanceText: string = '';
  @State isLoggedIn: boolean = false;
  @State currentAvatar: string = '';
  @State isCustomAvatar: boolean = false;
  @State showPresetAvatar: boolean = false;
  @State presetAvatarFile: string = AvatarUtils.DEFAULT_AVATAR_RAW;

  aboutToAppear() {
    ensureAppData();
    this.refreshProfile();
  }

  onPageShow() {
    this.refreshProfile();
  }

  refreshProfile() {
    this.isLoggedIn = GlobalStore.isLoggedIn();
    this.displayName = GlobalStore.getDisplayName();
    this.displayAccount = GlobalStore.getDisplayPhone();
    if (this.isLoggedIn) {
      this.balanceText = `账户余额：￥${GlobalStore.getUserBalance().toFixed(2)}`;
    } else {
      this.balanceText = '';
    }
    this.updateAvatar();
  }

  updateAvatar() {
    this.isCustomAvatar = false;
    this.currentAvatar = '';
    this.showPresetAvatar = false;
    this.presetAvatarFile = AvatarUtils.DEFAULT_AVATAR_RAW;
    if (GlobalStore.currentUser === null) {
      return;
    }
    let avatarName = GlobalStore.currentUser.avatar;
    if (GlobalStore.isCustomAvatarName(avatarName)) {
      this.currentAvatar = avatarName;
      this.isCustomAvatar = true;
    } else {
      this.presetAvatarFile = GlobalStore.getAvatarRawPath();
      this.showPresetAvatar = true;
    }
  }

  doLogout() {
    GlobalStore.logout();
    this.refreshProfile();
    promptAction.showToast({ message: '已退出登录' });
  }

  goLogin() {
    router.pushUrl({ url: 'pages/Login' });
  }

  navigateToEdit() {
    if (!GlobalStore.isLoggedIn()) {
      promptAction.showToast({ message: '请先登录' });
      this.goLogin();
      return;
    }
    router.pushUrl({ url: 'pages/edit' }).catch(() => {
      promptAction.showToast({ message: '无法打开编辑页' });
    });
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          Text('我的')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .width('100%')
            .padding({ left: 20, top: 16, bottom: 12 })

          Row() {
            if (this.isLoggedIn && this.isCustomAvatar && this.currentAvatar.length > 0) {
              Image(`file://${getContext(this).filesDir}/${this.currentAvatar}`)
                .width(72)
                .height(72)
                .borderRadius(36)
                .objectFit(ImageFit.Cover)
                .backgroundColor(AppTheme.BG_DISABLED)
            } else if (this.isLoggedIn && this.showPresetAvatar) {
              Image($rawfile(this.presetAvatarFile))
                .width(72)
                .height(72)
                .borderRadius(36)
                .objectFit(ImageFit.Cover)
                .backgroundColor(AppTheme.BG_DISABLED)
            } else {
              Circle({ width: 72, height: 72 })
                .fill(AppTheme.PRIMARY)
            }

            Column({ space: 6 }) {
              Text(this.displayName)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
              Text(this.displayAccount)
                .fontSize(14)
                .fontColor(AppTheme.TEXT_SECONDARY)
              if (this.isLoggedIn && this.balanceText.length > 0) {
                Text(this.balanceText)
                  .fontSize(14)
                  .fontColor(AppTheme.PRIMARY)
                  .fontWeight(FontWeight.Medium)
              }
              if (!this.isLoggedIn) {
                Button('去登录')
                  .fontSize(13)
                  .height(32)
                  .margin({ top: 4 })
                  .backgroundColor(AppTheme.PRIMARY)
                  .onClick(() => {
                    this.goLogin();
                  })
              }
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 16 })
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: 20, right: 20, bottom: 16 })
          .alignItems(VerticalAlign.Center)

          List() {
            ListItem() {
              this.ListItemBuilder($r('app.media.notice'), '推送通知')
            }
            ListItem() {
              this.ListItemBuilder($r('app.media.date'), '修改个人信息')
            }
            ListItem() {
              this.ListItemBuilder($r('app.media.information_77957'), '已购商品')
            }
            ListItem() {
              this.ListItemBuilder($r('app.media.ic_shop_logo'), '购物车')
            }
            ListItem() {
              this.ListItemBuilder($r('app.media.favorite'), '收藏商品')
            }
            ListItem() {
              this.CouponListItemBuilder()
            }
            ListItem() {
              this.ListItemBuilder($r('app.media.shield_77956'), '隐私协议')
            }
          }
          .divider({ strokeWidth: 1, color: AppTheme.BORDER_LIGHT })
          .width('100%')

          if (this.isLoggedIn) {
            Button('退出登录')
              .width('90%')
              .height(48)
              .fontSize(16)
              .fontColor(AppTheme.PRIMARY)
              .backgroundColor(AppTheme.BG_SIDEBAR)
              .margin({ top: 16, bottom: 8 })
              .onClick(() => {
                this.doLogout();
              })
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      BottomNavBar({ currentIndex: 2 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG_PAGE)
  }

  @Builder
  ListItemBuilder(iconRes: Resource, title: string) {
    Row() {
      Image(iconRes)
        .width(28)
        .height(28)
        .margin({ right: 16 })
      Text(title)
        .fontSize(16)
        .layoutWeight(1)
        .fontColor(AppTheme.TEXT_PRIMARY)
      Text('>')
        .fontSize(18)
        .fontColor(AppTheme.TEXT_HINT)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 14, bottom: 14 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (title === '修改个人信息') {
        this.navigateToEdit();
      } else if (title === '推送通知') {
        router.pushUrl({ url: 'pages/notice' });
      } else if (title === '隐私协议') {
        router.pushUrl({ url: 'pages/private' });
      } else if (title === '已购商品') {
        if (!GlobalStore.isLoggedIn()) {
          promptAction.showToast({ message: '请先登录' });
          this.goLogin();
          return;
        }
        router.pushUrl({ url: 'pages/OrderListPage' });
      } else if (title === '购物车') {
        router.pushUrl({ url: 'pages/CartPage' });
      } else if (title === '收藏商品') {
        router.pushUrl({ url: 'pages/FavoritePage' });
      }
    })
  }

  @Builder
  CouponListItemBuilder() {
    Row() {
      Image($r('app.media.yen_77950'))
        .width(28)
        .height(28)
        .margin({ right: 16 })
      Text('查看优惠券')
        .fontSize(16)
        .layoutWeight(1)
        .fontColor(AppTheme.TEXT_PRIMARY)
      Text('>')
        .fontSize(18)
        .fontColor(AppTheme.TEXT_HINT)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 14, bottom: 14 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (!GlobalStore.isLoggedIn()) {
        promptAction.showToast({ message: '请先登录' });
        this.goLogin();
        return;
      }
      router.pushUrl({ url: 'pages/CouponPage' });
    })
  }
}
