import router from '@ohos.router';
import productData from '../../../mock/product.json';
import { Product, GlobalStore, RouteParams, ProductUtils } from '../model/Models';
import { BottomNavBar } from '../components/BottomNavBar';

@Entry
@Component
struct RankPage {
  private products: Product[] = productData.data as Product[];
  @State rankList: Product[] = [];
  @State rankMode: number = 0;
  @State categories: string[] = [];
  @State selectedCategory: string = '';

  aboutToAppear() {
    GlobalStore.allProducts = this.products;
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
          .fontColor(this.rankMode === 0 ? '#E60012' : '#666666')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(this.rankMode === 0 ? Color.White : '#EEEEEE')
          .borderRadius({ topLeft: 8, bottomLeft: 8 })
          .onClick(() => {
            this.switchMode(0);
          })

        Text('分类排行')
          .fontSize(15)
          .fontWeight(this.rankMode === 1 ? FontWeight.Bold : FontWeight.Normal)
          .fontColor(this.rankMode === 1 ? '#E60012' : '#666666')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .padding({ top: 10, bottom: 10 })
          .backgroundColor(this.rankMode === 1 ? Color.White : '#EEEEEE')
          .borderRadius({ topRight: 8, bottomRight: 8 })
          .onClick(() => {
            this.switchMode(1);
          })
      }
      .width('92%')
      .margin({ bottom: 10 })

      if (this.rankMode === 1) {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.categories, (cat: string) => {
              Text(cat)
                .fontSize(13)
                .fontColor(this.selectedCategory === cat ? Color.White : '#666666')
                .backgroundColor(this.selectedCategory === cat ? '#E60012' : '#FFFFFF')
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .borderRadius(16)
                .border({
                  width: 1,
                  color: this.selectedCategory === cat ? '#E60012' : '#DDDDDD'
                })
                .onClick(() => {
                  this.selectCategory(cat);
                })
            }, (cat: string) => cat)
          }
          .padding({ left: 4, right: 4 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('92%')
        .height(44)
        .margin({ bottom: 8 })
      }

      if (this.rankMode === 1 && this.rankList.length === 0) {
        Text('该分类暂无商品')
          .fontSize(14)
          .fontColor('#999999')
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
    .backgroundColor('#F5F5F5')
  }

  @Builder
  RankItem(item: Product, index: number) {
    Row({ space: 12 }) {
      Text(`${index + 1}`)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(index < 3 ? '#E60012' : '#999999')
        .width(28)
        .textAlign(TextAlign.Center)
      Image($rawfile(item.images[0]))
        .width(72)
        .height(72)
        .borderRadius(8)
        .objectFit(ImageFit.Cover)
        .backgroundColor('#EEEEEE')
      Column({ space: 4 }) {
        if (this.rankMode === 1) {
          Text(item.category ?? '其他')
            .fontSize(11)
            .fontColor('#E60012')
        }
        Text(item.name)
          .fontSize(14)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(item.hot)
          .fontSize(12)
          .fontColor('#999999')
        Text(`￥${item.price}`)
          .fontSize(16)
          .fontColor('#E60012')
          .fontWeight(FontWeight.Medium)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(12)
    .backgroundColor(Color.White)
    .borderRadius(10)
    .onClick(() => {
      router.pushUrl({ url: 'pages/ProductDetail', params: { product: item } as RouteParams });
    })
  }
}
