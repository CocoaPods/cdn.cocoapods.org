# The new CDN, powered by GitHub Actions

Following the increasing cost and several outages on the Netlify service, it was decided to look for simpler alternatives.

The new build process uses GH Actions to create the static indices and runs roughly every 7 minutes. The result is deployed into a GitHub Pages environment.

The `CNAME` is currently set to `cdn2.cocoapods.org` for experimenting. This needs to change for production.

## How the CDN works

Our CDN works by taking the [CocoaPods Specs](https://github.com/CocoaPods/Specs/) repo and creating static files which tells the CocoaPods CLI what pods and versions exist currently.

The CocoaPods CLI will use the information from files like:

### `https://cdn.cocoapods.org/all_pods.txt`:

```
!ProtoCompiler
!ProtoCompiler-gRPCPlugin
+verify
-
0001
10Clock
120301
1210
1229Sdk
12306DeveCocoa
180305Pod
19WhereSVProgressHUD
1BAIDUSDKSYDemo
1PasswordExtension
1PasswordExtensionHaha
20170610test
20180408Test
...
```

There are a set of known [prefixes for all Podspec paths](https://blog.cocoapods.org/Master-Spec-Repo-Rate-Limiting-Post-Mortem/#too-many-directory-entries), you take the name of the pod, create a SHA (using md5) of it and take the first three characters.

E,g, for the Podspec name:`AppNetworkManager` -> `222d4d61b20ded1118cedbb42c07ce5f`. So, it lives at `2/2/2`.

the CocoaPods CLI can get a list of versions for all pods which live at `2/2/2` from these know indices:

### `https://cdn.cocoapods.org/all_pods_versions_2_2_2.txt`:

```
AppNetworkManager/1.0.0/1.0.1/1.0.2/1.0.4/1.0.5/1.0.6/1.0.7
BIZGrid4plus1CollectionViewLayout/1.0.0
ContactsWrapper/0.0.1/0.0.2/0.0.3/0.9/1.0/1.0.1/1.0.2
DfPodTest/0.0.1/0.0.2
GoogleConversionTracking/1.2.0/2.1.0/3.0.0/3.1.1/3.2.0/3.3.0/3.3.1/3.4.0
HZTabbar/0.0.1/0.0.2/0.0.3/0.0.4
IAPHelperLV/0.1.0/0.1.1/0.1.2
IDLib/0.2.0/0.3.0
...
```

Which means to get a podspec JSON, to ensure the CLI can resolve all your dependencies, then the CLI will make HTTP requests like these:

- `https://cdn.cocoapods.org/Specs/2/2/2/AppNetworkManager/1.0.0/AppNetworkManager.podspec.json`
- `https://cdn.cocoapods.org/Specs/2/2/2/ContactsWrapper/0.9/ContactsWrapper.podspec.json`
- `https://cdn.cocoapods.org/Specs/2/2/2/IDLib/0.2.0/IDLib.podspec.json`

Repeat this process for all the dependencies of your dependencies, and that is enough to be able to download just the Podspecs specs needed for your whole dependency tree. Meaning you don't need to do the full clone of the Specs repo.

## How the CDN is implemented

This repo is responsible for generating `all_pods.txt` and the sharded indices. That happens in [`Scripts/create_pods_and_versions_index.rb`](./Scripts/create_pods_and_versions_index.rb).

These files get pushed to the [GitHub Pages branch of this repo](./tree/gh-pages).

We then use CloudFlare CDN to redirect incoming URLs either to this repo's GitHub Pages static site, or to a [jsDelivr](https://www.jsdelivr.com) backed copy of the CocoaPods Specs repo based on this re-direct rule:

```
cdn.cocoapods.org/Specs/* ->
https://cdn.jsdelivr.net/cocoa/Specs/$1
```

This repo does not contain any redirect code as it's not possible to do so in GitHub Pages. 