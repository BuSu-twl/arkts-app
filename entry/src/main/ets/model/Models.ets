export interface Product {
  id: number;
  name: string;
  price: number;
  description: string;
  images: string[];
  shopname: string;
  hot: string;
  category?: string;
  count?: number;
}

export interface Coupon {
  id: string;
  threshold: number;
  discount: number;
  title: string;
}

export class ProductUtils {
  static parseHotValue(hot: string): number {
    if (!hot || hot.length === 0) {
      return 0;
    }
    let multiplier = 1;
    let work = hot;
    if (work.indexOf('万') >= 0) {
      multiplier = 10000;
      work = work.substring(0, work.indexOf('万'));
    }
    let digits = '';
    for (let i = 0; i < work.length; i++) {
      let c = work.charAt(i);
      if (c >= '0' && c <= '9') {
        digits += c;
      } else if (c === '.' && digits.indexOf('.') < 0) {
        digits += c;
      }
    }
    if (digits.length > 0) {
      return parseFloat(digits) * multiplier;
    }
    if (hot.indexOf('热销') >= 0 || hot.indexOf('人气') >= 0) {
      return 800;
    }
    return 50;
  }

  static sortByHotDesc(products: Product[]): Product[] {
    let result = products.slice();
    for (let i = 0; i < result.length - 1; i++) {
      for (let j = 0; j < result.length - 1 - i; j++) {
        if (ProductUtils.parseHotValue(result[j].hot) < ProductUtils.parseHotValue(result[j + 1].hot)) {
          let temp = result[j];
          result[j] = result[j + 1];
          result[j + 1] = temp;
        }
      }
    }
    return result;
  }

  static getTopHotProducts(products: Product[], count: number): Product[] {
    return ProductUtils.sortByHotDesc(products).slice(0, count);
  }

  static getAllCategories(products: Product[]): string[] {
    let categories: string[] = [];
    for (let i = 0; i < products.length; i++) {
      let cat = products[i].category ?? '其他';
      let exists = false;
      for (let j = 0; j < categories.length; j++) {
        if (categories[j] === cat) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        categories.push(cat);
      }
    }
    return categories;
  }

  static getProductsByCategory(products: Product[], category: string): Product[] {
    let result: Product[] = [];
    for (let i = 0; i < products.length; i++) {
      if ((products[i].category ?? '其他') === category) {
        result.push(products[i]);
      }
    }
    return result;
  }

  static getCategoryTopProducts(products: Product[]): Product[] {
    let categories: string[] = [];
    for (let i = 0; i < products.length; i++) {
      let cat = products[i].category ?? '其他';
      let exists = false;
      for (let j = 0; j < categories.length; j++) {
        if (categories[j] === cat) {
          exists = true;
          break;
        }
      }
      if (!exists) {
        categories.push(cat);
      }
    }
    let result: Product[] = [];
    for (let i = 0; i < categories.length; i++) {
      let best: Product | null = null;
      let bestHot = -1;
      for (let j = 0; j < products.length; j++) {
        if ((products[j].category ?? '其他') === categories[i]) {
          let hotVal = ProductUtils.parseHotValue(products[j].hot);
          if (hotVal > bestHot) {
            bestHot = hotVal;
            best = products[j];
          }
        }
      }
      if (best !== null) {
        result.push(best);
      }
    }
    return result;
  }
}

export interface RouteParams {
  product: Product;
}

export interface PayItem {
  productId: number;
  name: string;
  price: number;
  count: number;
  image: string;
}

export interface PayRouteParams {
  items: PayItem[];
  fromCart: boolean;
}

export interface PayResultParams {
  orderId: string;
  payAmount: number;
}

export interface Order {
  orderId: string;
  userId: number;
  items: PayItem[];
  totalAmount: number;
  discount: number;
  payAmount: number;
  couponId: string;
  payMethod: string;
  status: string;
  createTime: string;
}

/** 用户购物车条目：仅存商品 id 与数量 */
export interface UserCartItem {
  productId: number;
  count: number;
}

/** 与 mock/user.json 字段对应 */
export interface User {
  id: number;
  account: string;
  phone: string;
  memberName: string;
  password: string;
  nickname: string;
  avatar: string;
  smsCode: string;
  claimedCouponIds: string[];
  cartItems: UserCartItem[];
  favoriteIds: number[];
  orders: Order[];
  registerTime: string;
}

export class GlobalStore {
  static cartList: Product[] = [];
  static favoriteList: Product[] = [];
  static allProducts: Product[] = [];
  static claimedCouponIds: string[] = [];
  static orderList: Order[] = [];
  static allUsers: User[] = [];
  static currentUser: User | null = null;
  static usersLoaded: boolean = false;
  static pendingPay: PayRouteParams | null = null;

  static readonly COUPONS: Coupon[] = [
    { id: 'c1000', threshold: 1000, discount: 100, title: '满1000减100' },
    { id: 'c500', threshold: 500, discount: 60, title: '满500减60' },
    { id: 'c300', threshold: 300, discount: 20, title: '满300减20' },
    { id: 'c100', threshold: 100, discount: 10, title: '满100减10' },
    { id: 'c50', threshold: 50, discount: 5, title: '满50减5' },
  ];

  static isCouponClaimed(couponId: string): boolean {
    for (let i = 0; i < GlobalStore.claimedCouponIds.length; i++) {
      if (GlobalStore.claimedCouponIds[i] === couponId) {
        return true;
      }
    }
    return false;
  }

  static claimCoupon(couponId: string): boolean {
    if (GlobalStore.isCouponClaimed(couponId)) {
      return false;
    }
    GlobalStore.claimedCouponIds.push(couponId);
    GlobalStore.syncCouponsToCurrentUser();
    return true;
  }

  static copyStringArray(arr: string[]): string[] {
    let result: string[] = [];
    for (let i = 0; i < arr.length; i++) {
      result.push(arr[i]);
    }
    return result;
  }

  static copyUser(u: User): User {
    return {
      id: u.id,
      account: u.account,
      phone: u.phone,
      memberName: u.memberName,
      password: u.password,
      nickname: u.nickname,
      avatar: u.avatar,
      smsCode: u.smsCode,
      claimedCouponIds: GlobalStore.copyStringArray(u.claimedCouponIds),
      cartItems: GlobalStore.copyCartItems(u.cartItems ?? []),
      favoriteIds: GlobalStore.copyFavoriteIds(u.favoriteIds ?? []),
      orders: GlobalStore.copyOrders(u.orders ?? []),
      registerTime: u.registerTime
    };
  }

  static copyCartItems(items: UserCartItem[]): UserCartItem[] {
    let result: UserCartItem[] = [];
    for (let i = 0; i < items.length; i++) {
      result.push({
        productId: items[i].productId,
        count: items[i].count
      });
    }
    return result;
  }

  static copyFavoriteIds(ids: number[]): number[] {
    let result: number[] = [];
    for (let i = 0; i < ids.length; i++) {
      result.push(ids[i]);
    }
    return result;
  }

  static findProductById(productId: number): Product | null {
    for (let i = 0; i < GlobalStore.allProducts.length; i++) {
      if (GlobalStore.allProducts[i].id === productId) {
        return GlobalStore.allProducts[i];
      }
    }
    return null;
  }

  static buildProductWithCount(source: Product, count: number): Product {
    return {
      id: source.id,
      name: source.name,
      price: source.price,
      description: source.description,
      images: source.images,
      shopname: source.shopname,
      hot: source.hot,
      category: source.category,
      count: count
    };
  }

  static loadUserCart(user: User): void {
    GlobalStore.cartList = [];
    let items = user.cartItems ?? [];
    for (let i = 0; i < items.length; i++) {
      let source = GlobalStore.findProductById(items[i].productId);
      if (source !== null) {
        GlobalStore.cartList.push(GlobalStore.buildProductWithCount(source, items[i].count));
      }
    }
  }

  static loadUserFavorites(user: User): void {
    GlobalStore.favoriteList = [];
    let ids = user.favoriteIds ?? [];
    for (let i = 0; i < ids.length; i++) {
      let source = GlobalStore.findProductById(ids[i]);
      if (source !== null) {
        GlobalStore.favoriteList.push(GlobalStore.buildProductWithCount(source, 1));
      }
    }
  }

  static syncCartToCurrentUser(): void {
    if (GlobalStore.currentUser === null) {
      return;
    }
    let cartItems: UserCartItem[] = [];
    for (let i = 0; i < GlobalStore.cartList.length; i++) {
      cartItems.push({
        productId: GlobalStore.cartList[i].id,
        count: GlobalStore.cartList[i].count ?? 1
      });
    }
    GlobalStore.currentUser.cartItems = GlobalStore.copyCartItems(cartItems);
    let source = GlobalStore.findUserById(GlobalStore.currentUser.id);
    if (source !== null) {
      source.cartItems = GlobalStore.copyCartItems(cartItems);
    }
  }

  static syncFavoritesToCurrentUser(): void {
    if (GlobalStore.currentUser === null) {
      return;
    }
    let ids: number[] = [];
    for (let i = 0; i < GlobalStore.favoriteList.length; i++) {
      ids.push(GlobalStore.favoriteList[i].id);
    }
    GlobalStore.currentUser.favoriteIds = GlobalStore.copyFavoriteIds(ids);
    let source = GlobalStore.findUserById(GlobalStore.currentUser.id);
    if (source !== null) {
      source.favoriteIds = GlobalStore.copyFavoriteIds(ids);
    }
  }

  static persistSessionCartAndFavorites(): void {
    GlobalStore.syncCartToCurrentUser();
    GlobalStore.syncFavoritesToCurrentUser();
  }

  static copyOrder(o: Order): Order {
    return {
      orderId: o.orderId,
      userId: o.userId,
      items: GlobalStore.copyPayItems(o.items),
      totalAmount: o.totalAmount,
      discount: o.discount,
      payAmount: o.payAmount,
      couponId: o.couponId,
      payMethod: o.payMethod,
      status: o.status,
      createTime: o.createTime
    };
  }

  static copyOrders(orders: Order[]): Order[] {
    let result: Order[] = [];
    for (let i = 0; i < orders.length; i++) {
      result.push(GlobalStore.copyOrder(orders[i]));
    }
    return result;
  }

  static loadUserOrders(user: User): void {
    GlobalStore.orderList = GlobalStore.copyOrders(user.orders ?? []);
  }

  static syncOrdersToCurrentUser(): void {
    if (GlobalStore.currentUser === null) {
      return;
    }
    GlobalStore.currentUser.orders = GlobalStore.copyOrders(GlobalStore.orderList);
    let source = GlobalStore.findUserById(GlobalStore.currentUser.id);
    if (source !== null) {
      source.orders = GlobalStore.copyOrders(GlobalStore.orderList);
    }
  }

  static persistSessionOrders(): void {
    GlobalStore.syncOrdersToCurrentUser();
  }

  static initUsers(userList: User[]): void {
    if (GlobalStore.usersLoaded) {
      return;
    }
    GlobalStore.allUsers = [];
    for (let i = 0; i < userList.length; i++) {
      GlobalStore.allUsers.push(GlobalStore.copyUser(userList[i]));
    }
    GlobalStore.usersLoaded = true;
  }

  static findUserByAccount(account: string): User | null {
    for (let i = 0; i < GlobalStore.allUsers.length; i++) {
      let u = GlobalStore.allUsers[i];
      if (u.account === account || u.phone === account || u.memberName === account) {
        return u;
      }
    }
    return null;
  }

  static findUserByPhone(phone: string): User | null {
    for (let i = 0; i < GlobalStore.allUsers.length; i++) {
      if (GlobalStore.allUsers[i].phone === phone) {
        return GlobalStore.allUsers[i];
      }
    }
    return null;
  }

  static findUserById(userId: number): User | null {
    for (let i = 0; i < GlobalStore.allUsers.length; i++) {
      if (GlobalStore.allUsers[i].id === userId) {
        return GlobalStore.allUsers[i];
      }
    }
    return null;
  }

  static applyUserSession(user: User): void {
    let wasGuest = GlobalStore.currentUser === null;
    let guestCart = wasGuest ? GlobalStore.snapshotCart() : [];
    GlobalStore.persistSessionOrders();
    GlobalStore.persistSessionCartAndFavorites();
    GlobalStore.currentUser = GlobalStore.copyUser(user);
    GlobalStore.claimedCouponIds = GlobalStore.copyStringArray(GlobalStore.currentUser.claimedCouponIds);
    GlobalStore.loadUserOrders(GlobalStore.currentUser);
    GlobalStore.loadUserCart(GlobalStore.currentUser);
    GlobalStore.loadUserFavorites(GlobalStore.currentUser);
    if (wasGuest && guestCart.length > 0) {
      GlobalStore.mergeCartItemsIntoList(guestCart);
      GlobalStore.syncCartToCurrentUser();
    }
  }

  static snapshotCart(): UserCartItem[] {
    let result: UserCartItem[] = [];
    for (let i = 0; i < GlobalStore.cartList.length; i++) {
      result.push({
        productId: GlobalStore.cartList[i].id,
        count: GlobalStore.cartList[i].count ?? 1
      });
    }
    return result;
  }

  static mergeCartItemsIntoList(items: UserCartItem[]): void {
    for (let i = 0; i < items.length; i++) {
      let found = false;
      for (let j = 0; j < GlobalStore.cartList.length; j++) {
        if (GlobalStore.cartList[j].id === items[i].productId) {
          GlobalStore.cartList[j].count = (GlobalStore.cartList[j].count ?? 0) + items[i].count;
          found = true;
          break;
        }
      }
      if (!found) {
        let source = GlobalStore.findProductById(items[i].productId);
        if (source !== null) {
          GlobalStore.cartList.push(GlobalStore.buildProductWithCount(source, items[i].count));
        }
      }
    }
  }

  static setPendingPay(params: PayRouteParams): void {
    GlobalStore.pendingPay = {
      items: GlobalStore.copyPayItems(params.items),
      fromCart: params.fromCart
    };
  }

  static consumePendingPay(): PayRouteParams | null {
    if (GlobalStore.pendingPay === null) {
      return null;
    }
    let params: PayRouteParams = {
      items: GlobalStore.copyPayItems(GlobalStore.pendingPay.items),
      fromCart: GlobalStore.pendingPay.fromCart
    };
    GlobalStore.pendingPay = null;
    return params;
  }

  static isProductPurchased(productId: number): boolean {
    if (!GlobalStore.isLoggedIn()) {
      return false;
    }
    for (let i = 0; i < GlobalStore.orderList.length; i++) {
      let order = GlobalStore.orderList[i];
      for (let j = 0; j < order.items.length; j++) {
        if (order.items[j].productId === productId) {
          return true;
        }
      }
    }
    return false;
  }

  static getSortedCartList(): Product[] {
    let unpurchased: Product[] = [];
    let purchased: Product[] = [];
    for (let i = 0; i < GlobalStore.cartList.length; i++) {
      let item = GlobalStore.cartList[i];
      let copy = GlobalStore.buildProductWithCount(
        GlobalStore.findProductById(item.id) ?? item,
        item.count ?? 1
      );
      if (GlobalStore.isProductPurchased(item.id)) {
        purchased.push(copy);
      } else {
        unpurchased.push(copy);
      }
    }
    let result: Product[] = [];
    for (let i = 0; i < unpurchased.length; i++) {
      result.push(unpurchased[i]);
    }
    for (let i = 0; i < purchased.length; i++) {
      result.push(purchased[i]);
    }
    return result;
  }

  static findCartIndexByProductId(productId: number): number {
    for (let i = 0; i < GlobalStore.cartList.length; i++) {
      if (GlobalStore.cartList[i].id === productId) {
        return i;
      }
    }
    return -1;
  }

  static updateCartCount(productId: number, count: number): void {
    let index = GlobalStore.findCartIndexByProductId(productId);
    if (index >= 0) {
      GlobalStore.cartList[index].count = count;
      if (GlobalStore.isLoggedIn()) {
        GlobalStore.syncCartToCurrentUser();
      }
    }
  }

  static syncCouponsToCurrentUser(): void {
    if (GlobalStore.currentUser === null) {
      return;
    }
    GlobalStore.currentUser.claimedCouponIds = GlobalStore.copyStringArray(GlobalStore.claimedCouponIds);
    let source = GlobalStore.findUserById(GlobalStore.currentUser.id);
    if (source !== null) {
      source.claimedCouponIds = GlobalStore.copyStringArray(GlobalStore.claimedCouponIds);
    }
  }

  static isLoggedIn(): boolean {
    return GlobalStore.currentUser !== null;
  }

  static loginByPassword(account: string, password: string): boolean {
    let user = GlobalStore.findUserByAccount(account);
    if (user === null) {
      return false;
    }
    if (user.password !== password) {
      return false;
    }
    GlobalStore.applyUserSession(user);
    return true;
  }

  static loginBySms(phone: string, code: string): boolean {
    let user = GlobalStore.findUserByPhone(phone);
    if (user === null) {
      return false;
    }
    if (user.smsCode !== code) {
      return false;
    }
    GlobalStore.applyUserSession(user);
    return true;
  }

  static logout(): void {
    GlobalStore.persistSessionOrders();
    GlobalStore.persistSessionCartAndFavorites();
    GlobalStore.currentUser = null;
    GlobalStore.claimedCouponIds = [];
    GlobalStore.orderList = [];
    GlobalStore.cartList = [];
    GlobalStore.favoriteList = [];
  }

  static registerUser(phone: string, password: string, smsCode: string): User | null {
    if (phone.length !== 11) {
      return null;
    }
    if (password.length < 6) {
      return null;
    }
    if (GlobalStore.findUserByPhone(phone) !== null) {
      return null;
    }
    let maxId = 0;
    for (let i = 0; i < GlobalStore.allUsers.length; i++) {
      if (GlobalStore.allUsers[i].id > maxId) {
        maxId = GlobalStore.allUsers[i].id;
      }
    }
    let newId = maxId + 1;
    let suffix = phone.length >= 4 ? phone.substring(phone.length - 4) : phone;
    let newUser: User = {
      id: newId,
      account: phone,
      phone: phone,
      memberName: `user${newId}`,
      password: password,
      nickname: `用户${suffix}`,
      avatar: `${newId}.png`,
      smsCode: smsCode,
      claimedCouponIds: [],
      cartItems: [],
      favoriteIds: [],
      orders: [],
      registerTime: GlobalStore.formatNow().substring(0, 10)
    };
    GlobalStore.allUsers.push(GlobalStore.copyUser(newUser));
    let saved = GlobalStore.findUserByPhone(phone);
    if (saved === null) {
      return null;
    }
    GlobalStore.applyUserSession(saved);
    return GlobalStore.currentUser;
  }

  static resetPassword(phone: string, code: string, newPassword: string): boolean {
    let user = GlobalStore.findUserByPhone(phone);
    if (user === null || user.smsCode !== code) {
      return false;
    }
    user.password = newPassword;
    if (GlobalStore.currentUser !== null && GlobalStore.currentUser.id === user.id) {
      GlobalStore.currentUser.password = newPassword;
    }
    return true;
  }

  static getDisplayName(): string {
    if (GlobalStore.currentUser === null) {
      return '商城用户';
    }
    return GlobalStore.currentUser.nickname;
  }

  static getDisplayPhone(): string {
    if (GlobalStore.currentUser === null) {
      return '未登录';
    }
    return GlobalStore.currentUser.phone;
  }

  /** 头像路径，对应 rawfile/avatars/ 下文件，如 avatars/1.png */
  static getAvatarRawPath(): string {
    if (GlobalStore.currentUser === null) {
      return '';
    }
    let name = GlobalStore.currentUser.avatar;
    if (name.length === 0) {
      return '';
    }
    if (name.indexOf('avatars/') === 0) {
      return name;
    }
    return `avatars/${name}`;
  }

  static hasAvatar(): boolean {
    return GlobalStore.getAvatarRawPath().length > 0;
  }

  static addToCart(p: Product): boolean {
    let index = -1;
    for (let i = 0; i < GlobalStore.cartList.length; i++) {
      if (GlobalStore.cartList[i].id === p.id) {
        index = i;
        break;
      }
    }
    if (index !== -1) {
      GlobalStore.cartList[index].count = (GlobalStore.cartList[index].count ?? 0) + 1;
    } else {
      let source = GlobalStore.findProductById(p.id);
      if (source !== null) {
        GlobalStore.cartList.push(GlobalStore.buildProductWithCount(source, 1));
      } else {
        GlobalStore.cartList.push({
          id: p.id, name: p.name, price: p.price, description: p.description,
          images: p.images, shopname: p.shopname, hot: p.hot, category: p.category, count: 1,
        });
      }
    }
    if (GlobalStore.isLoggedIn()) {
      GlobalStore.syncCartToCurrentUser();
    }
    return true;
  }

  static addToFavorite(p: Product): boolean {
    if (!GlobalStore.isLoggedIn()) {
      return false;
    }
    let exists = false;
    for (let i = 0; i < GlobalStore.favoriteList.length; i++) {
      if (GlobalStore.favoriteList[i].id === p.id) {
        exists = true;
        break;
      }
    }
    if (!exists) {
      let source = GlobalStore.findProductById(p.id);
      if (source !== null) {
        GlobalStore.favoriteList.push(GlobalStore.buildProductWithCount(source, 1));
      } else {
        GlobalStore.favoriteList.push({
          id: p.id, name: p.name, price: p.price, description: p.description,
          images: p.images, shopname: p.shopname, hot: p.hot, category: p.category
        });
      }
    }
    GlobalStore.syncFavoritesToCurrentUser();
    return true;
  }

  static removeFromFavoriteByIndex(index: number): void {
    if (index >= 0 && index < GlobalStore.favoriteList.length) {
      GlobalStore.favoriteList.splice(index, 1);
      GlobalStore.syncFavoritesToCurrentUser();
    }
  }

  static removeFromCartByIndex(index: number): void {
    if (index >= 0 && index < GlobalStore.cartList.length) {
      GlobalStore.cartList.splice(index, 1);
      if (GlobalStore.isLoggedIn()) {
        GlobalStore.syncCartToCurrentUser();
      }
    }
  }

  static removeFromCartByProductId(productId: number): void {
    let index = GlobalStore.findCartIndexByProductId(productId);
    if (index >= 0) {
      GlobalStore.cartList.splice(index, 1);
      if (GlobalStore.isLoggedIn()) {
        GlobalStore.syncCartToCurrentUser();
      }
    }
  }

  static toPayItem(p: Product, count?: number): PayItem {
    return {
      productId: p.id,
      name: p.name,
      price: p.price,
      count: count ?? p.count ?? 1,
      image: p.images[0]
    };
  }

  static calcItemsTotal(items: PayItem[]): number {
    let sum = 0;
    for (let i = 0; i < items.length; i++) {
      sum += items[i].price * items[i].count;
    }
    return sum;
  }

  static getCouponById(couponId: string): Coupon | null {
    if (couponId.length === 0) {
      return null;
    }
    for (let i = 0; i < GlobalStore.COUPONS.length; i++) {
      if (GlobalStore.COUPONS[i].id === couponId) {
        return GlobalStore.COUPONS[i];
      }
    }
    return null;
  }

  static calcCouponDiscount(subtotal: number, couponId: string): number {
    let coupon = GlobalStore.getCouponById(couponId);
    if (coupon === null) {
      return 0;
    }
    if (subtotal >= coupon.threshold) {
      return coupon.discount;
    }
    return 0;
  }

  static getUsableCoupons(subtotal: number): Coupon[] {
    let result: Coupon[] = [];
    for (let i = 0; i < GlobalStore.COUPONS.length; i++) {
      let c = GlobalStore.COUPONS[i];
      if (GlobalStore.isCouponClaimed(c.id) && subtotal >= c.threshold) {
        result.push(c);
      }
    }
    return result;
  }

  static getBestCouponId(subtotal: number): string {
    let usable = GlobalStore.getUsableCoupons(subtotal);
    let bestId = '';
    let bestDiscount = 0;
    for (let i = 0; i < usable.length; i++) {
      if (usable[i].discount > bestDiscount) {
        bestDiscount = usable[i].discount;
        bestId = usable[i].id;
      }
    }
    return bestId;
  }

  static formatNow(): string {
    let d = new Date();
    let month = d.getMonth() + 1;
    let day = d.getDate();
    let hour = d.getHours();
    let minute = d.getMinutes();
    let ms = month < 10 ? `0${month}` : `${month}`;
    let ds = day < 10 ? `0${day}` : `${day}`;
    let hs = hour < 10 ? `0${hour}` : `${hour}`;
    let mins = minute < 10 ? `0${minute}` : `${minute}`;
    return `${d.getFullYear()}-${ms}-${ds} ${hs}:${mins}`;
  }

  static copyPayItems(items: PayItem[]): PayItem[] {
    let result: PayItem[] = [];
    for (let i = 0; i < items.length; i++) {
      result.push({
        productId: items[i].productId,
        name: items[i].name,
        price: items[i].price,
        count: items[i].count,
        image: items[i].image
      });
    }
    return result;
  }

  static createOrder(items: PayItem[], couponId: string, payMethod: string): Order | null {
    if (GlobalStore.currentUser === null) {
      return null;
    }
    let copiedItems = GlobalStore.copyPayItems(items);
    let subtotal = GlobalStore.calcItemsTotal(copiedItems);
    let discount = GlobalStore.calcCouponDiscount(subtotal, couponId);
    let order: Order = {
      orderId: `ORD${Date.now()}`,
      userId: GlobalStore.currentUser.id,
      items: copiedItems,
      totalAmount: subtotal,
      discount: discount,
      payAmount: subtotal - discount,
      couponId: couponId,
      payMethod: payMethod,
      status: 'paid',
      createTime: GlobalStore.formatNow()
    };
    GlobalStore.orderList.push(order);
    GlobalStore.syncOrdersToCurrentUser();
    return order;
  }

  static removeCartItemsForPayItems(items: PayItem[]): void {
    for (let i = GlobalStore.cartList.length - 1; i >= 0; i--) {
      for (let j = 0; j < items.length; j++) {
        if (GlobalStore.cartList[i].id === items[j].productId) {
          GlobalStore.cartList.splice(i, 1);
          break;
        }
      }
    }
    GlobalStore.syncCartToCurrentUser();
  }

  static getOrderById(orderId: string): Order | null {
    for (let i = 0; i < GlobalStore.orderList.length; i++) {
      if (GlobalStore.orderList[i].orderId === orderId) {
        return GlobalStore.orderList[i];
      }
    }
    return null;
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