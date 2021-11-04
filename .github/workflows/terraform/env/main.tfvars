environment = "main"

aaaa_records = {
  "5e.zbmowrey.com" = "d2ctarp2vmpznw.cloudfront.net"
}

mx_records = {
  "zbmowrey.com" : [
    "10 mail.protonmail.ch",
    "20 mailsec.protonmail.ch"
  ]
}

txt_records = {
  "zbmowrey.com" = [
    "protonmail-verification=ea4260ba3df52d268f36ab707e662db9a8caaa64",
    "v=spf1 include:_spf.protonmail.ch mx ~all",
  ]
  "_dmarc.zbmowrey.com" = ["v=DMARC1; p=none; rua=mailto:zb@zbmowrey.com"]
}

cname_records = {
  "v5ovgfocysfgiknwwxlo7fm3ax6rwufl._domainkey.zbmowrey.com" = "v5ovgfocysfgiknwwxlo7fm3ax6rwufl.dkim.amazonses.com"
   "qmg5aatpkrq7obcou2grvpqnsrkkv3b6._domainkey.zbmowrey.com" = "qmg5aatpkrq7obcou2grvpqnsrkkv3b6.dkim.amazonses.com"
   "protonmail3._domainkey.zbmowrey.com" = "protonmail3.domainkey.d2hfypnvtrf7upmspiqkg5tf2a2ynzawy5w25shesjfhrrkrjx57a.domains.proton.ch."
   "protonmail2._domainkey.zbmowrey.com" = "protonmail2.domainkey.d2hfypnvtrf7upmspiqkg5tf2a2ynzawy5w25shesjfhrrkrjx57a.domains.proton.ch."
   "protonmail._domainkey.zbmowrey.com" = "protonmail.domainkey.d2hfypnvtrf7upmspiqkg5tf2a2ynzawy5w25shesjfhrrkrjx57a.domains.proton.ch."
   "kudr72x2mm234es5bvwfj7ojawwfgp45._domainkey.zbmowrey.com" = "kudr72x2mm234es5bvwfj7ojawwfgp45.dkim.amazonses.com"
   "_884caa34f8ee43ffe0c15fc26b4208c6.5e.zbmowrey.com" = "_b5574f17bfbe4cf6f62a9b74e6e29052.qqqfmgwtgn.acm-validations.aws."
   "_6b66b92091431c840d93c4cc5b3efaf3.zbmowrey.com" = "_3b8887c3121dcdbc64251bf5c44d9562.bsgbmzkfwj.acm-validations.aws."
   "_17f54f2776ca9363efd360ad9cb865d8.zbmowrey.com" = "_7c848f91080afcb220ee5882e4e7a72a.chvvfdvqrj.acm-validations.aws."

}

create_api_domain_name = true