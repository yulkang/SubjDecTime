function [tf, metainfo] = ispkg(pkg)
% [tf, metainfo] = ispkg(pkg)
metainfo = meta.package.fromName(pkg);
tf = ~isempty(metainfo);