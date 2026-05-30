import router from '@ohos.router';
import { Product, GlobalStore, RouteParams, ProductUtils } from '../model/Models';
import { BottomNavBar } from '../components/BottomNavBar';
import { AppTheme } from '../common/AppTheme';
import { ensureAppData } from '../common/AppInit';

@Entry
@Component
struct RankPage {
  private products: Product[] = [];
  @State rankList: Product[] = [];
  @State rankMode: number = 0;
  @State categories: string[] = [];
  @State selectedCategory: string = '';

  aboutToAppear() {
    ensureAppData();
    this.products = GlobalStore.allProducts;
    this.categories = ProductUtils.getAllCategories(this.products);
    if (this.categories.length > 0) {
      this.selectedCategory = this.categories[0];
    }
    this.refreshRankList();
  }

  refreshRankList() {
    if (this.rankMode === 0) {
      this.rankList = ProductUtils.sortByHotDesc(this.products);
    } else {
      let filtered = ProductUtils.getProductsByCategory(this.products, this.selectedCategory);
      this.rankList = ProductUtils.sortByHotDesc(filtered);
    }
  }

  switchMode(mode: number) {
    this.rankMode = mode;
    this.refreshRankList();
  }

  selectCategory(cat: string) {
    this.selectedCategory = cat;
    this.refreshRankList();
  }

  build() {
    Column() {
      Text('热销排行榜')
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .padding({ left: 16, top: 16, bottom: 8 })

      Row({ space: 0 }) {
        Text('总排行')
          .fontSize(15)
          .fontWeight(this.rankMode === 0 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.rankMode === 0 ? AppTheme.PRIMARY : AppTheme.TEXT_SECONDARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(this.rankMode === 0 ? AppTheme.WHITE : AppTheme.BG_DISABLED)
          .borderRadius({ topLeft: 8, bottomLeft: 8 })
          .onClick(() => {
            this.switchMode(0);
          })

        Text('分类排行')
          .fontSize(15)
          .fontWeight(this.rankMode === 1 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.rankMode === 1 ? AppTheme.PRIMARY : AppTheme.TEXT_SECONDARY)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(this.rankMode === 1 ? AppTheme.WHITE : AppTheme.BG_DISABLED)
          .borderRadius({ topRight: 8, bottomRight: 8 })
          .onClick(() => {
            this.switchMode(1);
          })
      }
      .width('92%')
      .margin({ bottom: 10 })

      if (this.rankMode === 1) {
        Row() {
          Scroll() {
            Column() {
              ForEach(this.categories, (cat: string) => {
                Text(cat)
                  .fontSize(13)
                  .fontColor(this.selectedCategory === cat ? AppTheme.PRIMARY : AppTheme.TEXT_SECONDARY)
                  .fontWeight(this.selectedCategory === cat ? FontWeight.Medium : FontWeight.Normal)
                  .backgroundColor(this.selectedCategory === cat ? AppTheme.WHITE : AppTheme.BG_SIDEBAR)
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding({ top: 14, bottom: 14, left: 6, right: 6 })
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .border({
                    width: { left: this.selectedCategory === cat ? 3 : 0 },
                    color: AppTheme.PRIMARY
                  })
                  .onClick(() => {
                    this.selectCategory(cat);
                  })
              }, (cat: string) => cat)
            }
            .width('100%')
          }
          .scrollBar(BarState.Off)
          .width(88)
          .layoutWeight(0)
          .height('100%')
          .backgroundColor(AppTheme.BG_SIDEBAR)

          if (this.rankList.length === 0) {
            Column() {
              Text('该分类暂无商品')
                .fontSize(14)
                .fontColor(AppTheme.TEXT_HINT)
            }
            .layoutWeight(1)
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          } else {
            List({ space: 10 }) {
              ForEach(this.rankList, (item: Product, index: number) => {
                ListItem() {
                  this.RankItem(item, index)
                }
              }, (item: Product) => `rank-${this.rankMode}-${item.id}`)
            }
            .layoutWeight(1)
            .padding({ left: 8, right: 12 })
          }
        }
        .layoutWeight(1)
        .width('100%')
        .alignItems(VerticalAlign.Top)
      } else if (this.rankList.length === 0) {
        Text('暂无排行数据')
          .fontSize(14)
          .fontColor(AppTheme.TEXT_HINT)
          .margin({ top: 40 })
          .layoutWeight(1)
      } else {
        List({ space: 10 }) {
          ForEach(this.rankList, (item: Product, index: number) => {
            ListItem() {
              this.RankItem(item, index)
            }
          }, (item: Product) => `rank-${this.rankMode}-${item.id}`)
        }
        .layoutWeight(1)
        .width('92%')
        .margin({ bottom: 8 })
      }

      BottomNavBar({ currentIndex: 1 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.BG_PAGE)
  }

  @Builder
  RankItem(item: Product, index: number) {
    Row({ space: 12 }) {
      Text(`${index + 1}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(index < 3 ? AppTheme.PRIMARY : AppTheme.TEXT_HINT)
        .width(28)
        .textAlign(TextAlign.Center)
      Image($rawfile(ProductUtils.getProductImageFile(item)))
        .width(72)
        .height(72)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .backgroundColor(AppTheme.BG_DISABLED)
      Column({ space: 4 }) {
        Text(item.name)
          .fontSize(14)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(item.hot)
          .fontSize(12)
          .fontColor(AppTheme.TEXT_HINT)
        Text(`￥${item.price}`)
          .fontSize(16)
          .fontColor(AppTheme.PRIMARY)
          .fontWeight(FontWeight.Medium)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(AppTheme.WHITE)
    .borderRadius(10)
    .onClick(() => {
      router.pushUrl({ url: 'pages/ProductDetail', params: { product: item } as RouteParams });
    })
  }
}
