# The new CDN, powered by GitHub Actions

Following the increasing cost and several outages on the Netlify service, it was decided to look for simpler alternatives.

The new build process uses GH Actions to create the static indices and runs roughly every 7 minutes. The result is deployed into a GitHub Pages environment.

The repo does not contain any redirect code as it's not possible to do so in GH Pages. The `/Specs/*` redirect is handled by the CDN Proxy (Cloudflare).

The `CNAME` is currently set to `cdn2.cocoapods.org` for experimenting. This needs to change for production.
