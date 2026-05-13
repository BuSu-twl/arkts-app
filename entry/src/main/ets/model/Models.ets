export interface Product {
  id: number;
  name: string;
  price: number;
  description: string;
  images: string[];
  shopname: string;
  hot: string;
  count?: number;
}

export interface RouteParams {
  product: Product;
}

export class GlobalStore {
  static cartList: Product[] = [];
  static favoriteList: Product[] = [];
  static allProducts: Product[] = [];

  // 手动构造对象，避开 ... 报错
  static addToCart(p: Product) {
    let index = -1;
    for (let i = 0; i < GlobalStore.cartList.length; i++) {
      if (GlobalStore.cartList[i].id === p.id) { index = i; break; }
    }
    if (index !== -1) {
      GlobalStore.cartList[index].count = (GlobalStore.cartList[index].count ?? 0) + 1;
    } else {
      GlobalStore.cartList.push({
        id: p.id, name: p.name, price: p.price, description: p.description,
        images: p.images, shopname: p.shopname, hot: p.hot, count: 1,
      });
    }
  }

  static addToFavorite(p: Product) {
    let exists = false;
    for (let i = 0; i < GlobalStore.favoriteList.length; i++) {
      if (GlobalStore.favoriteList[i].id === p.id) { exists = true; break; }
    }
    if (!exists) {
      GlobalStore.favoriteList.push({
        id: p.id, name: p.name, price: p.price, description: p.description,
        images: p.images, shopname: p.shopname, hot: p.hot
      });
    }
  }

  // 洗牌
  static getRandomRecommend(num: number): Product[] {
    let temp = GlobalStore.allProducts.slice();
    let result: Product[] = [];
    for (let i = 0; i < Math.min(num, temp.length); i++) {
      let ran = Math.floor(Math.random() * temp.length);
      result.push(temp[ran]);
      temp.splice(ran, 1);
    }
    return result;
  }
}