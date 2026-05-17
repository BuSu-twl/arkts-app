import router from '@ohos.router';
import { AppTheme } from '../common/AppTheme';

@Component
export struct BottomNavBar {
  @Prop currentIndex: number = 0;

  build() {
    Row() {
      Column({ space: 4 }) {
        Text('首页')
          .fontSize(14)
          .fontColor(this.currentIndex === 0 ? AppTheme.PRIMARY : AppTheme.TEXT_SECONDARY)
          .fontWeight(this.currentIndex === 0 ? FontWeight.Bold : FontWeight.Normal)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        if (this.currentIndex !== 0) {
          router.replaceUrl({ url: 'pages/HomePage' });
        }
      })

      Column({ space: 4 }) {
        Text('排行榜')
          .fontSize(14)
          .fontColor(this.currentIndex === 1 ? AppTheme.PRIMARY : AppTheme.TEXT_SECONDARY)
          .fontWeight(this.currentIndex === 1 ? FontWeight.Bold : FontWeight.Normal)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        if (this.currentIndex !== 1) {
          router.replaceUrl({ url: 'pages/RankPage' });
        }
      })

      Column({ space: 4 }) {
        Text('个人中心')
          .fontSize(14)
          .fontColor(this.currentIndex === 2 ? AppTheme.PRIMARY : AppTheme.TEXT_SECONDARY)
          .fontWeight(this.currentIndex === 2 ? FontWeight.Bold : FontWeight.Normal)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        if (this.currentIndex !== 2) {
          router.replaceUrl({ url: 'pages/ProfilePage' });
        }
      })
    }
    .width('100%')
    .height(56)
    .padding({ top: 8, bottom: 8 })
    .backgroundColor(AppTheme.WHITE)
    .border({ width: { top: 1 }, color: AppTheme.BORDER })
  }
}
