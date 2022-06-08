# arex-hoppscotch

## hoppscotch
该项目fork开源项目[hoppscotch v2.2.1](https://github.com/hoppscotch/hoppscotch/releases/tag/v2.2.1)


## 开发环境

node v16.15.0

[包管理器pnpm](https://pnpm.io/)

## 安装依赖
pnpm i

## 起不来的问题
- npm install sentry-cli失败的解决方案。 \
npm set ENTRYCLI_CDNURL=https://cdn.npm.taobao.org/dist/sentry-cli \
npm set sentrycli_cdnurl=https://cdn.npm.taobao.org/dist/sentry-cli

## 启动命令

pnpm run dev

## 提交代码

fork的hoppscotch，含有commit检查，可使用 git commit -m "添加readme" --no-verify 忽略

## 打包docker镜像

直接push到github上，github action会自动构建镜像并推送到dockerhub上

