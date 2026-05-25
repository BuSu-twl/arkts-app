// index.ets
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { GlobalStore } from '../model/Models';

@Entry
@Component
struct ProfilePage {
  @State displayAccount: string = ''
  @State currentAvatar: string = ''
  @State isCustomAvatar: boolean = false

  aboutToAppear() {
    this.displayAccount = GlobalStore.getDisplayPhone();
    this.updateAvatar();
  }

  updateAvatar() {
    if (GlobalStore.currentUser !== null) {
      let avatarName = GlobalStore.currentUser.avatar;
      if (avatarName.length > 0) {
        if (avatarName.startsWith('custom_')) {
          this.currentAvatar = avatarName;
          this.isCustomAvatar = true;
        } else {
          this.currentAvatar = avatarName;
          this.isCustomAvatar = false;
        }
      }
    }
  }

  onPageShow() {
    this.displayAccount = GlobalStore.getDisplayPhone();
    this.updateAvatar();
  }

  navigateToEdit() {
    console.log('点击了修改个人信息，准备跳转到 edit');
    try {
      router.pushUrl({
        url: 'pages/edit'
      }).then(() => {
        console.log('跳转到edit页面成功');
      }).catch((err: Error) => {
        console.error('跳转失败:', err);
        promptAction.showToast({ message: '页面跳转失败: ' + err.message });
      });
    } catch (error) {
      console.error('跳转异常:', error);
      promptAction.showToast({ message: '页面跳转异常' });
    }
  }

  build() {
    Column() {
      Text('我的')
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ top: 20, bottom: 20, left: 20 })

      Row() {
        if (this.isCustomAvatar) {
          Image(`file://${getContext(this).filesDir}/${this.currentAvatar}`)
            .width(80)
            .height(80)
            .borderRadius(40)
            .objectFit(ImageFit.Cover)
            .margin({ right: 20 })
        } else {
          Image($r('app.media.user_77926'))
            .width(80)
            .height(80)
            .borderRadius(40)
            .objectFit(ImageFit.Cover)
            .margin({ right: 20 })
        }

        Column() {
          Text(GlobalStore.getDisplayName())
            .fontSize(28)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })
          Text(this.displayAccount)
            .fontSize(18)
            .fontColor(Color.Gray)
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ left: 30, right: 30, bottom: 30 })
      .alignItems(VerticalAlign.Center)

      List() {
        ListItem() {
          this.ListItemBuilder($r('app.media.notice'), '推送通知', Color.Green)
        }

        ListItem() {
          this.ListItemBuilder($r('app.media.date'), '修改个人信息', Color.Blue)
        }
        ListItem() {
          this.ListItemBuilder($r('app.media.information_77957'), '已购商品', '#800080')
        }

        ListItem() {
          this.ListItemBuilder($r('app.media.ic_shop_logo'), '购物车', Color.Red)
        }

        ListItem() {
          this.ListItemBuilder($r('app.media.star'), '收藏商品', Color.Orange)
        }

        ListItem() {
          this.ListItemBuilder($r('app.media.hierarchicalstructure_77982'), '菜单设置', Color.Orange)
        }

        ListItem() {
          this.CouponListItemBuilder()
        }

        ListItem() {
          this.ListItemBuilder($r('app.media.information_77957'), '关于', Color.Green)
        }

        ListItem() {
          this.ListItemBuilder($r('app.media.cancel1_77976'), '清除缓存', '#800080')
        }

        ListItem() {
          this.ListItemBuilder($r('app.media.shield_77956'), '隐私协议','#800080')
        }


      }
      .divider({ strokeWidth: 1, color: '#f0f0f0' })
      .width('100%')
      .layoutWeight(1)

      Button('退出登录')
        .width('90%')
        .height(50)
        .fontSize(20)
        .fontColor(Color.Red)
        .backgroundColor('#f0f0f0')
        .margin({ bottom: 30 })
        .onClick(() => {
          GlobalStore.logout();
          console.log('用户点击了退出登录');
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.White)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ListItemBuilder(iconRes: Resource, title: string, iconColor: ResourceColor) {
    Row() {
      Image(iconRes)
        .width(30)
        .height(30)
        .fillColor(iconColor)
        .margin({ right: 20 })

      Text(title)
        .fontSize(20)
        .layoutWeight(1)

      Text('>')
        .fontSize(24)
        .fontColor(Color.Gray)

    }
    .width('100%')
    .padding({ left: 30, right: 30, top: 15, bottom: 15 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      console.log('点击了:', title);
      if (title === '修改个人信息') {
        this.navigateToEdit();
      } else if (title === '推送通知') {
        router.pushUrl({ url: '/pages/notice' });
      } else if (title === '菜单设置') {
        console.log('菜单设置');
      } else if (title === '关于') {
        console.log('关于页面');
      } else if (title === '清除缓存') {
        console.log('清除缓存');
      } else if (title === '隐私协议') {
        console.log('隐私协议');
      } else if (title === '已购商品') {
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
        .width(30)
        .height(30)
        .fillColor(Color.Red)
        .margin({ right: 20 })

      Text('查看优惠券')
        .fontSize(20)
        .layoutWeight(1)

      Text('>')
        .fontSize(24)
        .fontColor(Color.Gray)
    }
    .width('100%')
    .padding({ left: 30, right: 30, top: 15, bottom: 15 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      console.log('用户点击了查看优惠券')
    })
  }
}
