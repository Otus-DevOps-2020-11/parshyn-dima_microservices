[docker]
%{ for i in range(length(names)) ~}
%{ if split("-", names[i])[0] ==  "docker" ~}
${addrs[i]}
%{ endif ~}
%{ endfor ~}
