// // path: entry/src/main/ets/pages/CartPage.ets
// import router from '@ohos.router';
// import { Product, GlobalStore, RouteParams } from '../model/Models';
//
// @Entry
// @Component
// struct CartPage {
//   @State cartList: Product[] = [];
//   @State total: number = 0;
//   @State recommends: Product[] = [];
//
//   aboutToAppear() {
//     this.refresh();
//     this.recommends = GlobalStore.getRandomRecommend(6);
//   }
//
//   refresh() {
//     this.cartList = [...GlobalStore.cartList];
//     let sum = 0;
//     this.cartList.forEach(i => sum += i.price * (i.count ?? 1));
//     this.total = sum;
//   }
//
//   build() {
//     Column() {
//       // 1. 顶部：增加首页跳转
//       Row() {
//         Text("首页").fontSize(16).fontColor('#E60012').fontWeight(FontWeight.Bold)
//           .onClick(() => router.replaceUrl({ url: 'pages/Index' }))
//         //Blank()
//         Text("购物车").fontSize(20).fontWeight(FontWeight.Bold).padding({left: 100})
//         Blank()
//       }.width('100%').padding(15).backgroundColor(Color.White)
//
//       // 2. 动态内容区
//       List({ space: 10 }) {
//         // 购物车内容/空状态
//         ListItem() {
//           if (this.cartList.length === 0) {
//             Column() {
//               Text("购物车是空的").margin(20).fontColor('#999')
//               Button("去挑选宝贝").backgroundColor('#E60012')
//                 .onClick(() => router.replaceUrl({ url: 'pages/Index' }))
//             }.width('100%').padding(30)
//           } else {
//             Column() {
//               ForEach(this.cartList, (item: Product, index: number) => {
//                 ListItem() {
//                   Row() {
//                     // 1. 商品图片
//                     Image($rawfile(item.images[0]))
//                       .width(85) // 稍微加大了一点点，更有视觉冲击力
//                       .height(85)
//                       .borderRadius(10)
//                       .backgroundColor('#F9F9F9')
//
//                     // 2. 中间信息区
//                     Column() {
//                       Text(item.name)
//                         .fontSize(15)
//                         .fontWeight(FontWeight.Medium)
//                         .maxLines(2) // 允许显示两行名，避免名字太长显示不全
//                         //.textOverflow(TextOverflow.Ellipsis)
//
//                       Blank() // 自动撑开上下间距
//
//                       Row() {
//                         Text(`￥${item.price}`)
//                           .fontColor('#E60012')
//                           .fontSize(18)
//                           .fontWeight(FontWeight.Bold)
//
//                         Blank()
//
//                         // 数量加减器
//                         Row() {
//                           Text("-")
//                             .width(28).height(28).textAlign(TextAlign.Center)
//                             .onClick(() => { if(item.count! > 1) item.count!--; this.refresh(); })
//
//                           Text(`${item.count}`)
//                             .width(35).height(28).textAlign(TextAlign.Center)
//                             .fontSize(13).backgroundColor('#F5F5F5')
//
//                           Text("+")
//                             .width(28).height(28).textAlign(TextAlign.Center)
//                             .onClick(() => { item.count!++; this.refresh(); })
//                         }
//                         .border({ width: 1, color: '#F0F0F0' })
//                         .borderRadius(4)
//                       }
//                       .width('100%')
//                     }
//                     .layoutWeight(1)
//                     .height(85) // 和图片高度对齐
//                     .margin({ left: 12, right: 10 })
//                     .alignItems(HorizontalAlign.Start)
//
//                     // 3. 侧边删除区：把原来的 "x" 换成一个显眼的红色垃圾桶图标或文字块
//                     Column() {
//                       // 使用内置图标或者文字
//                       Text("删除")
//                         .fontSize(12)
//                         .fontColor(Color.White)
//                         .backgroundColor('#FF4D4F') // 漂亮的红色背景
//                         .padding({ left: 8, right: 8, top: 4, bottom: 4 })
//                         .borderRadius(6)
//                         .onClick(() => {
//                           // 增加二次确认，防止误删
//                           AlertDialog.show({
//                             title: '提示',
//                             message: '确定要移除这件商品吗？',
//                             primaryButton: {
//                               value: '取消',
//                               action: () => {}
//                             },
//                             secondaryButton: {
//                               value: '删除',
//                               fontColor: Color.Red,
//                               action: () => {
//                                 GlobalStore.cartList.splice(index, 1);
//                                 this.refresh();
//                               }
//                             }
//                           })
//                         })
//                     }
//                     .justifyContent(FlexAlign.Center)
//                   }
//                   .padding(12)
//                   .backgroundColor(Color.White)
//                   .borderRadius(16)
//                   .margin({ bottom: 12 })
//                   .shadow({ radius: 8, color: '#08000000', offsetY: 4 })
//                 }
//               })
//             }
//           }
//         }
//
//         // 猜你喜欢
//         ListItem() {
//           Column() {
//             Text("—— 猜你喜欢 ——").fontSize(12).fontColor('#999').margin(15)
//             Grid() {
//               ForEach(this.recommends, (item: Product) => {
//                 GridItem() {
//                   Column() {
//                     Image($rawfile(item.images[0])).width('100%').height(100).objectFit(ImageFit.Cover)
//                     Text(item.name).fontSize(11).maxLines(1).margin(5)
//                     Button("加购").fontSize(10).height(20).backgroundColor('#E60012')
//                       .onClick(() => { GlobalStore.addToCart(item); this.refresh(); })
//                   }.backgroundColor(Color.White).borderRadius(8).padding(5)
//                   .onClick(() => router.pushUrl({ url: 'pages/ProductDetail', params: { product: item } as RouteParams }))
//                 }
//               })
//             }.columnsTemplate('1fr 1fr').columnsGap(8).rowsGap(8).height(450)
//           }
//         }
//       }
//       .layoutWeight(1)
//       .width('94%')
//
//       // 3. 结算栏（始终固定在底部，不随滚动消失）
//       Row() {
//         Text(`合计: ￥${this.total.toFixed(2)}`).fontColor('#E60012').fontSize(20).fontWeight(FontWeight.Bold)
//         Blank()
//         Button("立即结算").backgroundColor(this.total > 0 ? '#E60012' : '#CCC').enabled(this.total > 0)
//       }.width('100%').padding(20).backgroundColor(Color.White).shadow({ radius: 5, color: '#10000000', offsetY: -3 })
//     }
//     .backgroundColor('#F5F5F5').height('100%')
//   }
// }
// path: entry/src/main/ets/pages/CartPage.ets
import router from '@ohos.router';
import { Product, GlobalStore, RouteParams } from '../model/Models';

@Entry
@Component
struct CartPage {
  @State cartList: Product[] = [];
  @State total: number = 0;
  @State recommends: Product[] = [];
  // 存储每个商品是否被选中，key为商品id或临时索引
  @State selectedItems: Set<number> = new Set();
  // 全选状态
  @State isAllSelected: boolean = false;

  aboutToAppear() {
    this.refresh();
    this.recommends = GlobalStore.getRandomRecommend(6);
  }

  refresh() {
    this.cartList = [...GlobalStore.cartList];
    // 清理已删除商品的选中状态
    const validIds = new Set(this.cartList.map(item => item.id));
    const newSelected = new Set<number>();
    this.selectedItems.forEach(id => {
      if (validIds.has(id)) {
        newSelected.add(id);
      }
    });
    this.selectedItems = newSelected;
    // 重新计算总价
    this.calcTotal();
    // 更新全选状态
    this.updateAllSelectedStatus();
  }

  // 计算选中商品的总价
  calcTotal() {
    let sum = 0;
    this.cartList.forEach(item => {
      if (this.selectedItems.has(item.id)) {
        sum += item.price * (item.count ?? 1);
      }
    });
    this.total = sum;
  }

  // 切换单个商品的选中状态
  toggleSelect(item: Product) {
    if (this.selectedItems.has(item.id)) {
      this.selectedItems.delete(item.id);
    } else {
      this.selectedItems.add(item.id);
    }
    // 触发UI更新
    this.selectedItems = new Set(this.selectedItems);
    this.calcTotal();
    this.updateAllSelectedStatus();
  }

  // 全选/取消全选
  toggleSelectAll() {
    if (this.isAllSelected) {
      this.selectedItems.clear();
    } else {
      this.cartList.forEach(item => {
        this.selectedItems.add(item.id);
      });
    }
    this.selectedItems = new Set(this.selectedItems);
    this.calcTotal();
    this.updateAllSelectedStatus();
  }

  // 更新全选状态
  updateAllSelectedStatus() {
    if (this.cartList.length === 0) {
      this.isAllSelected = false;
      return;
    }
    const allSelected = this.cartList.every(item => this.selectedItems.has(item.id));
    this.isAllSelected = allSelected;
  }

  build() {
    Column() {
      // 1. 顶部：增加首页跳转
      Row() {
        Text("首页").fontSize(16).fontColor('#E60012').fontWeight(FontWeight.Bold)
          .onClick(() => router.replaceUrl({ url: 'pages/Index' }))
        Text("购物车").fontSize(20).fontWeight(FontWeight.Bold).layoutWeight(1).textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding(15)
      .backgroundColor(Color.White)

      // 2. 动态内容区
      List({ space: 10 }) {
        // 购物车内容/空状态
        ListItem() {
          if (this.cartList.length === 0) {
            Column() {
              Text("购物车是空的").margin(20).fontColor('#999')
              Button("去挑选宝贝").backgroundColor('#E60012')
                .onClick(() => router.replaceUrl({ url: 'pages/Index' }))
            }
            .width('100%')
            .padding(30)
          } else {
            Column() {
              // 全选栏（新增）
              Row() {
                Row() {
                  Image(this.isAllSelected ? $r('app.media.Select') : $r('app.media.unselect'))
                    .width(20)
                    .height(20)
                    .margin({ right: 8 })
                  Text(this.isAllSelected ? "取消全选" : "全选")
                    .fontSize(14)
                    .fontColor('#333')
                }
                .onClick(() => this.toggleSelectAll())
                .padding({ left: 12 })

                Blank()

                Text("已选商品直接结算")
                  .fontSize(12)
                  .fontColor('#999')
                  .padding({ right: 12 })
              }
              .width('100%')
              .padding({ top: 8, bottom: 8 })
              .backgroundColor('#F8F8F8')

              ForEach(this.cartList, (item: Product, index: number) => {
                ListItem() {
                  Row() {
                    // 0. 复选框（新增）
                    Column() {
                      Image(this.selectedItems.has(item.id) ? $r('app.media.Select') : $r('app.media.unselect'))
                        .width(22)
                        .height(22)
                        .onClick(() => this.toggleSelect(item))
                    }
                    .padding({ right: 8 })
                    .justifyContent(FlexAlign.Center)

                    // 1. 商品图片
                    Image($rawfile(item.images[0]))
                      .width(85)
                      .height(85)
                      .borderRadius(10)
                      .backgroundColor('#F9F9F9')

                    // 2. 中间信息区
                    Column() {
                      Text(item.name)
                        .fontSize(15)
                        .fontWeight(FontWeight.Medium)
                        .maxLines(2)

                      Blank()

                      Row() {
                        Text(`￥${item.price}`)
                          .fontColor('#E60012')
                          .fontSize(18)
                          .fontWeight(FontWeight.Bold)

                        Blank()

                        Row() {
                          Text("-")
                            .width(28).height(28).textAlign(TextAlign.Center)
                            .onClick(() => {
                              if (item.count! > 1) item.count!--;
                              this.refresh();
                            })

                          Text(`${item.count}`)
                            .width(35).height(28).textAlign(TextAlign.Center)
                            .fontSize(13).backgroundColor('#F5F5F5')

                          Text("+")
                            .width(28).height(28).textAlign(TextAlign.Center)
                            .onClick(() => {
                              item.count!++;
                              this.refresh();
                            })
                        }
                        .border({ width: 1, color: '#F0F0F0' })
                        .borderRadius(4)
                      }
                      .width('100%')
                    }
                    .layoutWeight(1)
                    .height(85)
                    .margin({ left: 12, right: 10 })
                    .alignItems(HorizontalAlign.Start)

                    // 3. 删除按钮
                    Column() {
                      Text("删除")
                        .fontSize(12)
                        .fontColor(Color.White)
                        .backgroundColor('#FF4D4F')
                        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                        .borderRadius(6)
                        .onClick(() => {
                          AlertDialog.show({
                            title: '提示',
                            message: '确定要移除这件商品吗？',
                            primaryButton: {
                              value: '取消',
                              action: () => {}
                            },
                            secondaryButton: {
                              value: '删除',
                              fontColor: Color.Red,
                              action: () => {
                                GlobalStore.cartList.splice(index, 1);
                                this.refresh();
                              }
                            }
                          })
                        })
                    }
                    .justifyContent(FlexAlign.Center)
                  }
                  .padding(12)
                  .backgroundColor(Color.White)
                  .borderRadius(16)
                  .margin({ bottom: 12 })
                  .shadow({ radius: 8, color: '#08000000', offsetY: 4 })
                }
              })
            }
          }
        }

        // 猜你喜欢
        ListItem() {
          Column() {
            Text("—— 猜你喜欢 ——").fontSize(12).fontColor('#999').margin(15)
            Grid() {
              ForEach(this.recommends, (item: Product) => {
                GridItem() {
                  Column() {
                    Image($rawfile(item.images[0])).width('100%').height(100).objectFit(ImageFit.Cover)
                    Text(item.name).fontSize(11).maxLines(1).margin(5)
                    Button("加购").fontSize(10).height(20).backgroundColor('#E60012')
                      .onClick(() => {
                        GlobalStore.addToCart(item);
                        this.refresh();
                      })
                  }
                  .backgroundColor(Color.White)
                  .borderRadius(8)
                  .padding(5)
                  .onClick(() => router.pushUrl({ url: 'pages/ProductDetail', params: { product: item } as RouteParams }))
                }
              })
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(8)
            .rowsGap(8)
            .height(450)
          }
        }
      }
      .layoutWeight(1)
      .width('94%')

      // 3. 结算栏（底部）
      Row() {
        // 左侧增加全选快捷操作（可选）
        Row() {
          Image(this.isAllSelected ? $r('app.media.Select') : $r('app.media.unselect'))
            .width(20)
            .height(20)
            .margin({ right: 4 })
          Text("全选")
            .fontSize(14)
            .fontColor('#333')
        }
        .onClick(() => this.toggleSelectAll())
        .margin({ right: 16 })

        Text(`合计: ￥${this.total.toFixed(2)}`)
          .fontColor('#E60012')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)

        Button("立即结算")
          .backgroundColor(this.total > 0 ? '#E60012' : '#CCC')
          .enabled(this.total > 0)
          .onClick(() => {
            if (this.total > 0) {
              AlertDialog.show({
                title: '结算',
                message: `共选中 ${this.selectedItems.size} 件商品，合计 ￥${this.total.toFixed(2)}，\n是否确认购买？`,
                confirm: {
                  value: '去支付',
                  action: () => {
                    // 模拟结算成功，移除已购买的商品（根据实际业务调整）
                    const newCart = GlobalStore.cartList.filter(item => !this.selectedItems.has(item.id));
                    GlobalStore.cartList = newCart;
                    this.refresh();
                    router.replaceUrl({ url: 'pages/Index' });
                  }
                },
                cancel: () => {}
              });
            }
          })
      }
      .width('100%')
      .padding(20)
      .backgroundColor(Color.White)
      .shadow({ radius: 5, color: '#10000000', offsetY: -3 })
    }
    .backgroundColor('#F5F5F5')
    .height('100%')
  }
}