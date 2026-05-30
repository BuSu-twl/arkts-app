import { UserPersistence } from '../common/UserPersistence';
import { AvatarUtils } from '../common/AvatarUtils';

export interface Product {
  id: number;
  name: string;
  price: number;
  description: string;
  images: string[];
  shopname: string;
  /** rawfile 店铺头像，如 avatars/img/storeImg/1.png */
  shopAvatar?: string;
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

  static getBestProductInCategory(products: Product[], category: string): Product | null {
    let best: Product | null = null;
    let bestHot = -1;
    for (let j = 0; j < products.length; j++) {
      if ((products[j].category ?? '其他') === category) {
        let hotVal = ProductUtils.parseHotValue(products[j].hot);
        if (hotVal > bestHot) {
          bestHot = hotVal;
          best = products[j];
        }
      }
    }
    return best;
  }

  static getCategoryPeakHot(products: Product[], category: string): number {
    let best = ProductUtils.getBestProductInCategory(products, category);
    if (best === null) {
      return 0;
    }
    return ProductUtils.parseHotValue(best.hot);
  }

  static getProductsForCategories(products: Product[], categories: string[]): Product[] {
    let result: Product[] = [];
    for (let i = 0; i < categories.length; i++) {
      let best = ProductUtils.getBestProductInCategory(products, categories[i]);
      if (best !== null) {
        result.push(best);
      }
    }
    return result;
  }

  /** 按各分类热度峰值排序，取前 count 个品类 */
  static pickTopCategoriesByHot(products: Product[], count: number): string[] {
    let categories = ProductUtils.getAllCategories(products);
    let ranked = categories.slice();
    for (let i = 0; i < ranked.length - 1; i++) {
      for (let j = 0; j < ranked.length - 1 - i; j++) {
        let hotA = ProductUtils.getCategoryPeakHot(products, ranked[j]);
        let hotB = ProductUtils.getCategoryPeakHot(products, ranked[j + 1]);
        if (hotA < hotB) {
          let temp = ranked[j];
          ranked[j] = ranked[j + 1];
          ranked[j + 1] = temp;
        }
      }
    }
    let limit = count < ranked.length ? count : ranked.length;
    return ranked.slice(0, limit);
  }

  static getCategoryTopProducts(products: Product[]): Product[] {
    return ProductUtils.getProductsForCategories(products, ProductUtils.getAllCategories(products));
  }

  static getProductImageFile(product: Product): string {
    if (product.images !== undefined && product.images.length > 0 && product.images[0].length > 0) {
      return product.images[0];
    }
    return '1.png';
  }

  static readonly DEFAULT_SHOP_AVATAR_RAW: string = 'avatars/img/storeImg/1.png';

  static getShopAvatarRawPath(product: Product): string {
    if (product.shopAvatar !== undefined && product.shopAvatar.length > 0) {
      return product.shopAvatar;
    }
    return ProductUtils.DEFAULT_SHOP_AVATAR_RAW;
  }

  /** 订单项图片：兼容 mock 中 productN.jpg，回退到商品 catalog */
  static resolvePayItemImage(item: PayItem): string {
    if (item.image !== undefined && item.image.length > 0) {
      let img = item.image;
      if (img.endsWith('.jpg') && img.indexOf('product') >= 0) {
        let digits = '';
        for (let i = 0; i < img.length; i++) {
          let c = img.charAt(i);
          if (c >= '0' && c <= '9') {
            digits += c;
          }
        }
        if (digits.length > 0) {
          return `${digits}.png`;
        }
      }
      if (img.endsWith('.png')) {
        return img;
      }
    }
    let p = GlobalStore.findProductById(item.productId);
    if (p !== null) {
      return ProductUtils.getProductImageFile(p);
    }
    return '1.png';
  }
}

interface CategoryScore {
  category: string;
  score: number;
}

interface ScoredProduct {
  product: Product;
  score: number;
}

/** 基于用户行为的规则推荐 */
export class RecommendUtils {
  static addCategoryScore(scores: CategoryScore[], category: string, delta: number): void {
    if (delta <= 0) {
      return;
    }
    let cat = category.length > 0 ? category : '其他';
    for (let i = 0; i < scores.length; i++) {
      if (scores[i].category === cat) {
        scores[i].score += delta;
        return;
      }
    }
    scores.push({ category: cat, score: delta });
  }

  static getCategoryWeight(scores: CategoryScore[], category: string): number {
    let cat = category.length > 0 ? category : '其他';
    for (let i = 0; i < scores.length; i++) {
      if (scores[i].category === cat) {
        return scores[i].score;
      }
    }
    return 0;
  }

  static sortCategoryScoresDesc(scores: CategoryScore[]): CategoryScore[] {
    let result = scores.slice();
    for (let i = 0; i < result.length - 1; i++) {
      for (let j = 0; j < result.length - 1 - i; j++) {
        if (result[j].score < result[j + 1].score) {
          let temp = result[j];
          result[j] = result[j + 1];
          result[j + 1] = temp;
        }
      }
    }
    return result;
  }

  static containsId(ids: number[], id: number): boolean {
    for (let i = 0; i < ids.length; i++) {
      if (ids[i] === id) {
        return true;
      }
    }
    return false;
  }

  static getProductCategory(productId: number, products: Product[]): string {
    for (let i = 0; i < products.length; i++) {
      if (products[i].id === productId) {
        return products[i].category ?? '其他';
      }
    }
    return '其他';
  }

  static buildCategoryWeights(user: User, browseIds: number[], products: Product[]): CategoryScore[] {
    let scores: CategoryScore[] = [];
    let orders = user.orders ?? [];
    for (let i = 0; i < orders.length; i++) {
      let items = orders[i].items;
      for (let j = 0; j < items.length; j++) {
        let cat = RecommendUtils.getProductCategory(items[j].productId, products);
        RecommendUtils.addCategoryScore(scores, cat, 5);
      }
    }
    let favIds = user.favoriteIds ?? [];
    for (let i = 0; i < favIds.length; i++) {
      let cat = RecommendUtils.getProductCategory(favIds[i], products);
      RecommendUtils.addCategoryScore(scores, cat, 3);
    }
    let cartItems = user.cartItems ?? [];
    for (let i = 0; i < cartItems.length; i++) {
      let cat = RecommendUtils.getProductCategory(cartItems[i].productId, products);
      RecommendUtils.addCategoryScore(scores, cat, 2);
    }
    for (let i = 0; i < browseIds.length; i++) {
      let cat = RecommendUtils.getProductCategory(browseIds[i], products);
      RecommendUtils.addCategoryScore(scores, cat, 1);
    }
    return RecommendUtils.sortCategoryScoresDesc(scores);
  }

  static getCategoryRankBonus(categoryScores: CategoryScore[], category: string): number {
    let cat = category.length > 0 ? category : '其他';
    for (let i = 0; i < categoryScores.length && i < 3; i++) {
      if (categoryScores[i].category === cat) {
        if (i === 0) {
          return 15;
        }
        if (i === 1) {
          return 12;
        }
        return 10;
      }
    }
    let weight = RecommendUtils.getCategoryWeight(categoryScores, cat);
    if (weight > 0) {
      return 6;
    }
    return 0;
  }

  static scoreProduct(
    product: Product,
    categoryScores: CategoryScore[],
    favoriteIds: number[],
    cartProductIds: number[],
    isPurchased: boolean
  ): number {
    if (isPurchased) {
      return -1;
    }
    let score = 0;
    let cat = product.category ?? '其他';
    score += RecommendUtils.getCategoryRankBonus(categoryScores, cat);
    if (RecommendUtils.containsId(favoriteIds, product.id)) {
      score += 8;
    }
    if (RecommendUtils.containsId(cartProductIds, product.id)) {
      score += 5;
    }
    score += ProductUtils.parseHotValue(product.hot) / 1000;
    return score;
  }

  static sortScoredProductsDesc(items: ScoredProduct[]): ScoredProduct[] {
    let result = items.slice();
    for (let i = 0; i < result.length - 1; i++) {
      for (let j = 0; j < result.length - 1 - i; j++) {
        if (result[j].score < result[j + 1].score) {
          let temp = result[j];
          result[j] = result[j + 1];
          result[j + 1] = temp;
        }
      }
    }
    return result;
  }

  static hasBehaviorSignals(categoryScores: CategoryScore[]): boolean {
    return categoryScores.length > 0;
  }

  static buildCategoryWeightsForUser(user: User | null, browseIds: number[], products: Product[]): CategoryScore[] {
    if (user !== null) {
      return RecommendUtils.buildCategoryWeights(user, browseIds, products);
    }
    let scores: CategoryScore[] = [];
    for (let i = 0; i < browseIds.length; i++) {
      let cat = RecommendUtils.getProductCategory(browseIds[i], products);
      RecommendUtils.addCategoryScore(scores, cat, 1);
    }
    return RecommendUtils.sortCategoryScoresDesc(scores);
  }

  /** 分类精选：取兴趣分最高的 count 个品类，每类展示热度最高的一件 */
  static getInterestCategoryFeatured(
    products: Product[],
    user: User | null,
    browseIds: number[],
    count: number
  ): Product[] {
    if (products.length === 0 || count <= 0) {
      return [];
    }
    let categoryScores = RecommendUtils.buildCategoryWeightsForUser(user, browseIds, products);
    let selected: string[] = [];
    if (RecommendUtils.hasBehaviorSignals(categoryScores)) {
      for (let i = 0; i < categoryScores.length && selected.length < count; i++) {
        selected.push(categoryScores[i].category);
      }
    } else {
      selected = ProductUtils.pickTopCategoriesByHot(products, count);
    }
    return ProductUtils.getProductsForCategories(products, selected);
  }

  static getPersonalizedRecommend(
    products: Product[],
    user: User | null,
    browseIds: number[],
    purchasedIds: number[],
    count: number
  ): Product[] {
    if (products.length === 0 || count <= 0) {
      return [];
    }
    if (user === null) {
      return ProductUtils.getTopHotProducts(products, count);
    }
    let categoryScores = RecommendUtils.buildCategoryWeights(user, browseIds, products);
    if (!RecommendUtils.hasBehaviorSignals(categoryScores)) {
      return ProductUtils.getTopHotProducts(products, count);
    }
    let favoriteIds = user.favoriteIds ?? [];
    let cartProductIds: number[] = [];
    let cartItems = user.cartItems ?? [];
    for (let i = 0; i < cartItems.length; i++) {
      cartProductIds.push(cartItems[i].productId);
    }
    let scored: ScoredProduct[] = [];
    for (let i = 0; i < products.length; i++) {
      let purchased = RecommendUtils.containsId(purchasedIds, products[i].id);
      let s = RecommendUtils.scoreProduct(products[i], categoryScores, favoriteIds, cartProductIds, purchased);
      if (s >= 0) {
        scored.push({ product: products[i], score: s });
      }
    }
    let sorted = RecommendUtils.sortScoredProductsDesc(scored);
    let result: Product[] = [];
    for (let i = 0; i < sorted.length && result.length < count; i++) {
      result.push(sorted[i].product);
    }
    if (result.length < count) {
      let hotFallback = ProductUtils.getTopHotProducts(products, count);
      for (let i = 0; i < hotFallback.length && result.length < count; i++) {
        let exists = false;
        for (let j = 0; j < result.length; j++) {
          if (result[j].id === hotFallback[i].id) {
            exists = true;
            break;
          }
        }
        let purchased = RecommendUtils.containsId(purchasedIds, hotFallback[i].id);
        if (!exists && !purchased) {
          result.push(hotFallback[i]);
        }
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
  browseHistory?: number[];
  /** 账户余额（元），内存 mock */
  balance?: number;
  orders: Order[];
  registerTime: string;
}

export class GlobalStore {
  static cartList: Product[] = [];
  static favoriteList: Product[] = [];
  static allProducts: Product[] = [];
  static claimedCouponIds: string[] = [];
  static orderList: Order[] = [];
  static browseHistory: number[] = [];
  static allUsers: User[] = [];
  static currentUser: User | null = null;
  static readonly MAX_BROWSE_HISTORY: number = 20;
  static usersLoaded: boolean = false;
  static productsLoaded: boolean = false;
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
    GlobalStore.persistUsersToDisk();
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
      browseHistory: GlobalStore.copyProductIds(u.browseHistory ?? []),
      balance: GlobalStore.normalizeMoney(u.balance ?? 1000),
      orders: GlobalStore.copyOrders(u.orders ?? []),
      registerTime: u.registerTime
    };
  }

  static normalizeMoney(n: number): number {
    return Math.round(n * 100) / 100;
  }

  static copyProductIds(ids: number[]): number[] {
    let result: number[] = [];
    for (let i = 0; i < ids.length; i++) {
      result.push(ids[i]);
    }
    return result;
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
      shopAvatar: source.shopAvatar,
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

  static loadUserBrowseHistory(user: User): void {
    GlobalStore.browseHistory = GlobalStore.copyProductIds(user.browseHistory ?? []);
  }

  static syncBrowseToCurrentUser(): void {
    if (GlobalStore.currentUser === null) {
      return;
    }
    GlobalStore.currentUser.browseHistory = GlobalStore.copyProductIds(GlobalStore.browseHistory);
    let source = GlobalStore.findUserById(GlobalStore.currentUser.id);
    if (source !== null) {
      source.browseHistory = GlobalStore.copyProductIds(GlobalStore.browseHistory);
    }
  }

  static recordBrowse(productId: number): void {
    if (productId <= 0) {
      return;
    }
    let next: number[] = [];
    next.push(productId);
    for (let i = 0; i < GlobalStore.browseHistory.length; i++) {
      if (GlobalStore.browseHistory[i] !== productId) {
        next.push(GlobalStore.browseHistory[i]);
      }
    }
    if (next.length > GlobalStore.MAX_BROWSE_HISTORY) {
      next = next.slice(0, GlobalStore.MAX_BROWSE_HISTORY);
    }
    GlobalStore.browseHistory = next;
    GlobalStore.syncBrowseToCurrentUser();
  }

  static getPurchasedProductIds(): number[] {
    let ids: number[] = [];
    for (let i = 0; i < GlobalStore.orderList.length; i++) {
      let order = GlobalStore.orderList[i];
      for (let j = 0; j < order.items.length; j++) {
        let pid = order.items[j].productId;
        if (!RecommendUtils.containsId(ids, pid)) {
          ids.push(pid);
        }
      }
    }
    return ids;
  }

  static buildRecommendUserSnapshot(): User | null {
    if (GlobalStore.currentUser === null) {
      return null;
    }
    let snapshot = GlobalStore.copyUser(GlobalStore.currentUser);
    let cartItems: UserCartItem[] = [];
    for (let i = 0; i < GlobalStore.cartList.length; i++) {
      cartItems.push({
        productId: GlobalStore.cartList[i].id,
        count: GlobalStore.cartList[i].count ?? 1
      });
    }
    snapshot.cartItems = GlobalStore.copyCartItems(cartItems);
    let favIds: number[] = [];
    for (let i = 0; i < GlobalStore.favoriteList.length; i++) {
      favIds.push(GlobalStore.favoriteList[i].id);
    }
    snapshot.favoriteIds = GlobalStore.copyFavoriteIds(favIds);
    snapshot.orders = GlobalStore.copyOrders(GlobalStore.orderList);
    snapshot.browseHistory = GlobalStore.copyProductIds(GlobalStore.browseHistory);
    return snapshot;
  }

  static getPersonalizedRecommend(count: number): Product[] {
    let user = GlobalStore.buildRecommendUserSnapshot();
    return RecommendUtils.getPersonalizedRecommend(
      GlobalStore.allProducts,
      user,
      GlobalStore.browseHistory,
      GlobalStore.getPurchasedProductIds(),
      count
    );
  }

  static getCategoryFeaturedRecommend(count: number): Product[] {
    let user = GlobalStore.buildRecommendUserSnapshot();
    return RecommendUtils.getInterestCategoryFeatured(
      GlobalStore.allProducts,
      user,
      GlobalStore.browseHistory,
      count
    );
  }

  static getPersonalRecommendHint(): string {
    if (!GlobalStore.isLoggedIn()) {
      return '登录后根据收藏、购物车与浏览记录推荐';
    }
    let user = GlobalStore.buildRecommendUserSnapshot();
    if (user === null) {
      return '';
    }
    let scores = RecommendUtils.buildCategoryWeights(user, user.browseHistory ?? [], GlobalStore.allProducts);
    if (!RecommendUtils.hasBehaviorSignals(scores)) {
      return '暂无足够行为数据，先按热销推荐';
    }
    return `Hi，${GlobalStore.getDisplayName()}，根据你的兴趣推荐`;
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

  /** 写回 allUsers 并保存到沙箱 user_data.json */
  static persistUsersToDisk(): void {
    if (GlobalStore.currentUser !== null) {
      GlobalStore.persistSessionOrders();
      GlobalStore.persistSessionCartAndFavorites();
      GlobalStore.syncCouponsToCurrentUser();
      GlobalStore.syncBrowseToCurrentUser();
      GlobalStore.syncBalanceToCurrentUser();
      for (let i = 0; i < GlobalStore.allUsers.length; i++) {
        let cu = GlobalStore.currentUser;
        if (cu !== null && GlobalStore.allUsers[i].id === cu.id) {
          GlobalStore.allUsers[i] = GlobalStore.copyUser(cu);
          break;
        }
      }
    }
    UserPersistence.saveUsers(GlobalStore.allUsers as Object[]);
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
    let guestBrowse = wasGuest ? GlobalStore.copyProductIds(GlobalStore.browseHistory) : [];
    GlobalStore.persistSessionOrders();
    GlobalStore.persistSessionCartAndFavorites();
    GlobalStore.currentUser = GlobalStore.copyUser(user);
    GlobalStore.claimedCouponIds = GlobalStore.copyStringArray(GlobalStore.currentUser.claimedCouponIds);
    GlobalStore.loadUserOrders(GlobalStore.currentUser);
    GlobalStore.loadUserCart(GlobalStore.currentUser);
    GlobalStore.loadUserFavorites(GlobalStore.currentUser);
    GlobalStore.loadUserBrowseHistory(GlobalStore.currentUser);
    if (wasGuest && guestBrowse.length > 0) {
      GlobalStore.mergeBrowseIds(guestBrowse);
      GlobalStore.syncBrowseToCurrentUser();
    }
    if (wasGuest && guestCart.length > 0) {
      GlobalStore.mergeCartItemsIntoList(guestCart);
      GlobalStore.syncCartToCurrentUser();
    }
  }

  static mergeBrowseIds(ids: number[]): void {
    for (let i = 0; i < ids.length; i++) {
      GlobalStore.recordBrowse(ids[i]);
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

  static logout(): void {
    GlobalStore.persistUsersToDisk();
    GlobalStore.currentUser = null;
    GlobalStore.claimedCouponIds = [];
    GlobalStore.orderList = [];
    GlobalStore.cartList = [];
    GlobalStore.favoriteList = [];
    GlobalStore.browseHistory = [];
  }

  static registerUser(phone: string, password: string): User | null {
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
      avatar: AvatarUtils.DEFAULT_AVATAR_STORED,
      smsCode: '',
      claimedCouponIds: [],
      cartItems: [],
      favoriteIds: [],
      browseHistory: [],
      balance: 200,
      orders: [],
      registerTime: GlobalStore.formatNow().substring(0, 10)
    };
    GlobalStore.allUsers.push(GlobalStore.copyUser(newUser));
    let saved = GlobalStore.findUserByPhone(phone);
    if (saved === null) {
      return null;
    }
    GlobalStore.applyUserSession(saved);
    GlobalStore.persistUsersToDisk();
    return GlobalStore.currentUser;
  }

  static resetPassword(phone: string, newPassword: string): boolean {
    let user = GlobalStore.findUserByPhone(phone);
    if (user === null) {
      return false;
    }
    user.password = newPassword;
    if (GlobalStore.currentUser !== null && GlobalStore.currentUser.id === user.id) {
      GlobalStore.currentUser.password = newPassword;
    }
    GlobalStore.persistUsersToDisk();
    return true;
  }

  static updateUserPhone(newPhone: string): boolean {
    if (GlobalStore.currentUser === null) {
      return false;
    }
    if (newPhone.length !== 11) {
      return false;
    }
    let existing = GlobalStore.findUserByPhone(newPhone);
    if (existing !== null && existing.id !== GlobalStore.currentUser.id) {
      return false;
    }
    GlobalStore.currentUser.phone = newPhone;
    GlobalStore.currentUser.account = newPhone;
    let user = GlobalStore.findUserById(GlobalStore.currentUser.id);
    if (user !== null) {
      user.phone = newPhone;
      user.account = newPhone;
    }
    GlobalStore.persistUsersToDisk();
    return true;
  }

  static getPayMethodLabel(method: string): string {
    if (method === 'balance') {
      return '余额';
    }
    if (method === 'wechat') {
      return '微信';
    }
    if (method === 'alipay') {
      return '支付宝';
    }
    return '余额';
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

  static getUserBalance(): number {
    if (GlobalStore.currentUser === null) {
      return 0;
    }
    return GlobalStore.normalizeMoney(GlobalStore.currentUser.balance ?? 0);
  }

  static syncBalanceToCurrentUser(): void {
    if (GlobalStore.currentUser === null) {
      return;
    }
    let b = GlobalStore.normalizeMoney(GlobalStore.currentUser.balance ?? 0);
    GlobalStore.currentUser.balance = b;
    let source = GlobalStore.findUserById(GlobalStore.currentUser.id);
    if (source !== null) {
      source.balance = b;
    }
  }

  /** 头像 $rawfile 路径；custom_ 为沙箱自定义头像文件名 */
  static getAvatarRawPath(): string {
    if (GlobalStore.currentUser === null) {
      return '';
    }
    return AvatarUtils.resolveRawfilePath(GlobalStore.currentUser.avatar);
  }

  static isCustomAvatarName(name: string): boolean {
    return AvatarUtils.isCustomAvatar(name);
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
          images: p.images, shopname: p.shopname, shopAvatar: p.shopAvatar, hot: p.hot, category: p.category, count: 1,
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
          images: p.images, shopname: p.shopname, shopAvatar: p.shopAvatar, hot: p.hot, category: p.category
        });
      }
    }
    GlobalStore.syncFavoritesToCurrentUser();
    return true;
  }

  static isProductFavorited(productId: number): boolean {
    for (let i = 0; i < GlobalStore.favoriteList.length; i++) {
      if (GlobalStore.favoriteList[i].id === productId) {
        return true;
      }
    }
    return false;
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
    let image = '1.png';
    if (p.images !== undefined && p.images.length > 0 && p.images[0].length > 0) {
      image = p.images[0];
    }
    return {
      productId: p.id,
      name: p.name,
      price: p.price,
      count: count ?? p.count ?? 1,
      image: image
    };
  }

  static calcItemsTotal(items: PayItem[]): number {
    let sum = 0;
    for (let i = 0; i < items.length; i++) {
      sum += items[i].price * items[i].count;
    }
    return sum;
  }

  static getClaimedCoupons(): Coupon[] {
    let result: Coupon[] = [];
    for (let i = 0; i < GlobalStore.COUPONS.length; i++) {
      if (GlobalStore.isCouponClaimed(GlobalStore.COUPONS[i].id)) {
        result.push(GlobalStore.COUPONS[i]);
      }
    }
    return result;
  }

  static getUnclaimedCoupons(): Coupon[] {
    let result: Coupon[] = [];
    for (let i = 0; i < GlobalStore.COUPONS.length; i++) {
      if (!GlobalStore.isCouponClaimed(GlobalStore.COUPONS[i].id)) {
        result.push(GlobalStore.COUPONS[i]);
      }
    }
    return result;
  }

  static syncClaimedCouponsFromCurrentUser(): void {
    if (GlobalStore.currentUser !== null) {
      GlobalStore.claimedCouponIds = GlobalStore.copyStringArray(GlobalStore.currentUser.claimedCouponIds);
    }
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
    if (payMethod !== 'balance') {
      return null;
    }
    let copiedItems = GlobalStore.copyPayItems(items);
    let subtotal = GlobalStore.calcItemsTotal(copiedItems);
    let discount = GlobalStore.calcCouponDiscount(subtotal, couponId);
    let payAmount = GlobalStore.normalizeMoney(subtotal - discount);
    let bal = GlobalStore.getUserBalance();
    if (bal < payAmount) {
      return null;
    }
    let order: Order = {
      orderId: `ORD${Date.now()}`,
      userId: GlobalStore.currentUser.id,
      items: copiedItems,
      totalAmount: subtotal,
      discount: discount,
      payAmount: payAmount,
      couponId: couponId,
      payMethod: payMethod,
      status: 'paid',
      createTime: GlobalStore.formatNow()
    };
    GlobalStore.orderList.push(order);
    GlobalStore.currentUser.balance = GlobalStore.normalizeMoney(bal - payAmount);
    GlobalStore.syncBalanceToCurrentUser();
    GlobalStore.syncOrdersToCurrentUser();
    GlobalStore.persistUsersToDisk();
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