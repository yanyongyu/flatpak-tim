<!--
 * @Author         : yanyongyu
 * @Date           : 2020-04-13 21:52:56
 * @LastEditors    : yanyongyu
 * @LastEditTime   : 2020-04-14 14:42:11
 * @Description    : None
 * @GitHub         : https://github.com/yanyongyu
 -->

# 构建安装

## 安装依赖

```shell
flatpak install flathub org.freedesktop.Platform/i386/18.08
flatpak install flathub org.freedesktop.Sdk/i386/18.08
```

## 安装运行时

[com.deepin.wine](https://github.com/yanyongyu/flatpak-deepin-wine-ubuntu)

## 构建 APP

```shell
flatpak-builder --repo=repo --arch=i386 .build deepin.com.qq.office.json
```

## 测试 APP

```shell
flatpak-builder --run .build deepin.com.qq.office.json run.sh -h
```

## 安装 APP

```shell
flatpak remote-add --user --no-gpg-verify repo-tim ./repo
flatpak install --user repo-tim deepin.com.qq.office
```
