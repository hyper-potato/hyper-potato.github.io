#!/bin/bash
# 判断public文件夹是否存在
hugoPath=`pwd`
publicPath=`pwd`"/public"
if [ ! -d $publicPath ];then
  echo public not exist
  exit
fi

# 进入public文件夹，并清空之前生成文件
cd $publicPath
rm -r ./*

# 回到根目录，并生成新的静态文件
cd $hugoPath
hugo

# 回到public，并进行提交
cd $publicPath

#添加所有修改
git checkout master
git add -A .

# 设置提交说明，格式为 Site updated: 2006-01-02 15:04:05
time=$(date "+%Y-%m-%d %H:%M:%S")
commit="Site updated:"$time
echo $commit

#提交
git commit -m "$commit"

#推送到master分支上
git push origin master
