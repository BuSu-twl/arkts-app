import router from '@ohos.router';
import productData from '../../../mock/product.json';
import { Product, GlobalStore, RouteParams } from '../model/Models';

@Entry
@Component
struct Index {
  private products: Product[] = productData.data as Product[];

  aboutToAppear() {
    GlobalStore.allProducts = this.products;
  }

  build() {
    Column() {
      Text("精选商城").fontSize(24).fontWeight(FontWeight.Bold).margin(20)

      List({ space: 15 }) {
        ForEach(this.products, (item: Product) => {
          ListItem() {
            this.ProductCard(item)
          }
        })
      }.layoutWeight(1).width('95%')

      // 底部导航模拟
      Row() {
        Text("首页").fontColor('#E60012').fontWeight(FontWeight.Bold)
        Text("收藏").onClick(() => router.pushUrl({ url: 'pages/FavoritePage' }))
        Text("购物车").onClick(() => router.pushUrl({ url: 'pages/CartPage' }))
      }.width('100%').justifyContent(FlexAlign.SpaceAround).padding(15).backgroundColor(Color.White)
    }.backgroundColor('#F5F5F5').height('100%')
  }

  @Builder ProductCard(item: Product) {
    Row() {
      Image($rawfile(item.images[0])).width(100).height(100).borderRadius(8).backgroundColor('#EEE')
      Column() {
        Text(item.name).fontSize(16).maxLines(2)
        Text(`￥${item.price}`).fontColor('#E60012').fontSize(20).margin({ top: 10 })
      }.margin({ left: 15 }).alignItems(HorizontalAlign.Start).layoutWeight(1)
    }
    .padding(15).backgroundColor(Color.White).borderRadius(12)
    .onClick(() => { router.pushUrl({ url: 'pages/ProductDetail', params: { product: item } as RouteParams }) })
  }
}