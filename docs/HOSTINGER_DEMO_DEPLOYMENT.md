# Hostinger demo deployment

The GitHub Actions workflow in `.github/workflows/hostinger-demo.yml` builds
the Flutter web app whenever `main` changes and publishes the compiled output
to the `hostinger-deploy` branch.

## One-time Hostinger setup

1. In hPanel, create or select the custom HTML website for `xantarapos.com`.
2. Open **Websites > xantarapos.com > Git**.
3. Choose the private repository option and copy the SSH deploy key generated
   by Hostinger.
4. In GitHub, open **rixensjohn/xantarapos > Settings > Deploy keys**, add the
   Hostinger key with read-only access, and return to hPanel.
5. Configure the repository as `git@github.com:rixensjohn/xantarapos.git`, use
   the `hostinger-deploy` branch, and leave the install path empty so the files
   are deployed to `public_html`.
6. Run the first deployment, enable Hostinger auto-deployment, and add its
   webhook under **GitHub > Settings > Webhooks** if hPanel does not add it
   automatically.
7. Enable SSL and force HTTPS for `xantarapos.com`.

The demo uses browser-local storage. Its data is not shared between devices
and should not be treated as production records.
