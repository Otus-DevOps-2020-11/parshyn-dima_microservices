[gitlab]
%{ for i in range(length(names)) ~}
%{ if split("-", names[i])[0] ==  "gitlab" ~}
${addrs[i]}
%{ endif ~}
%{ endfor ~}
[runner]
%{ for i in range(length(names_runner)) ~}
%{ if split("-", names_runner[i])[0] ==  "runner" ~}
${addrs_runner[i]}
%{ endif ~}
%{ endfor ~}
