import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import { Order, PayItem, GlobalStore } from '../model/Models';

@Entry
@Component
struct OrderListPage {
  @State orders: Order[] = [];

  aboutToAppear() {
    this.refreshOrders();
  }

  onPageShow() {
    this.refreshOrders();
  }

  refreshOrders() {
    if (!GlobalStore.isLoggedIn()) {
      this.orders = [];
      return;
    }
    this.orders = GlobalStore.copyOrders(GlobalStore.orderList);
  }

  getPayMethodLabel(method: string): string {
    if (method === 'wechat') {
      return '微信';
    }
    if (method === 'alipay') {
      return '支付宝';
    }
    return '余额';
  }

  build() {
    Column() {
      Row() {
        Text('< 返回')
          .fontSize(16)
          .onClick(() => {
            router.back();
          })
        Text('我的订单')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Text('')
          .width(48)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)

      if (!GlobalStore.isLoggedIn()) {
        Column() {
          Text('请先登录查看订单')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 80 })
          Button('去登录')
            .backgroundColor('#E60012')
            .margin({ top: 20 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/Login' });
            })
        }
        .layoutWeight(1)
      } else if (this.orders.length === 0) {
        Column() {
          Text('暂无订单')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ top: 80 })
          Button('去逛逛')
            .backgroundColor('#E60012')
            .margin({ top: 20 })
            .onClick(() => {
              router.replaceUrl({ url: 'pages/HomePage' });
            })
        }
        .layoutWeight(1)
      } else {
        List({ space: 12 }) {
          ForEach(this.orders, (order: Order) => {
            ListItem() {
              Column({ space: 8 }) {
                Row() {
                  Text(order.createTime)
                    .fontSize(12)
                    .fontColor('#999999')
                  Blank()
                  Text(order.status === 'paid' ? '已支付' : order.status)
                    .fontSize(12)
                    .fontColor('#E60012')
                }
                .width('100%')

                ForEach(order.items, (item: PayItem) => {
                  Row({ space: 8 }) {
                    Image($rawfile(item.image))
                      .width(48)
                      .height(48)
                      .borderRadius(6)
                      .backgroundColor('#EEEEEE')
                    Column({ space: 2 }) {
                      Text(item.name)
                        .fontSize(13)
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Text(`￥${item.price} x${item.count}`)
                        .fontSize(12)
                        .fontColor('#666666')
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                }, (item: PayItem) => `oi-${order.orderId}-${item.productId}`)

                Row() {
                  Text(`${this.getPayMethodLabel(order.payMethod)}支付`)
                    .fontSize(12)
                    .fontColor('#999999')
                  Blank()
                  Text(`实付 ￥${order.payAmount.toFixed(2)}`)
                    .fontSize(15)
                    .fontColor('#E60012')
                    .fontWeight(FontWeight.Medium)
                }
                .width('100%')
                .margin({ top: 4 })

                Text(`订单号：${order.orderId}`)
                  .fontSize(11)
                  .fontColor('#BBBBBB')
                  .width('100%')
              }
              .width('100%')
              .padding(14)
              .backgroundColor(Color.White)
              .borderRadius(10)
            }
          }, (order: Order) => order.orderId)
        }
        .layoutWeight(1)
        .width('94%')
        .margin({ top: 8 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
