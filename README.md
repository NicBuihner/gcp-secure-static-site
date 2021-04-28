# What

Example of how to deploy a static website that's protected by GCP's Identity
Aware Proxy.

# Why?

Me personally, I like the static sites 💎🤲. Why would you want to do this?
I've managed WordPress sites off and on for close to ten years and it's
cultivate a deep love of static website generators.  My favorite being
[Hugo](https://gohugo.io/). The cloud providers have the ability to turn their
storage solutions like S3 and GCP Cloud Storage buckets into websites, but
there's no mechanism for utilizing the built-in authentication in those
platforms.

> But it's a static site, why do you need authentication?

There are plenty of situations you might want this. Internal documentation,
godocs or sphinx docs that aren't appropriate for public consumption, static
hosting mechanisms for an SPA, etc. The biggest advantage is using cloud
services from top to bottom so that you end up with a low administrative
footprint. Once you have this setup, you won't even need to update SSL
certificates ever again let alone apply patches to servers. It becomes a
solution that requires exactly the opposite amount of management that a
WordPress site in the hands of a high school teacher with a plugin fetish.

# How

![Architecture Diagram](https://raw.githubusercontent.com/NicBuihner/gcp-secure-static-site/main/docs/res/GCPSecureStaticSite.png)
