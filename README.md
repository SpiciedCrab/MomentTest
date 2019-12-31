# Demo for Moment


- 以简便的`RxSwift` 为基础，放弃了 `RxDataSources` 部分绑定 `data` 逻辑，`vc` 中还是普通代理模式， 	`vm` 中使用流逻辑来处理数据。

- `vm` 中可以注入可选的插件，分别用来获取数据，验证数据，分组数据，在 `UT` 中可以通过替换插件的具体实现，来测试 `viewModel` 处理是否正确， 同样开发阶段也可以通过实现自己的插件来实现自己逻辑同时又不影响 `viewModel` 中主要逻辑

- `UI` 层 以 `collectionView` 为基础，每个 `section` 为一个用户的 `tweet`， `section` 中分多种 `row`， 分别显示 `content` , `images` , `comments`
