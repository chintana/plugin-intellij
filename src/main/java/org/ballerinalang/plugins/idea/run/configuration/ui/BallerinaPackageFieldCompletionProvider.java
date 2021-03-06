/*
 *  Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

package org.ballerinalang.plugins.idea.run.configuration.ui;

import com.intellij.codeInsight.completion.CompletionResultSet;
import com.intellij.codeInsight.lookup.LookupElementBuilder;
import com.intellij.openapi.module.Module;
import com.intellij.openapi.project.Project;
import com.intellij.openapi.vfs.VirtualFile;
import com.intellij.util.Producer;
import com.intellij.util.TextFieldCompletionProvider;
import org.jetbrains.annotations.NotNull;

import java.io.File;

public class BallerinaPackageFieldCompletionProvider extends TextFieldCompletionProvider {

    @NotNull
    private final Producer<Module> myModuleProducer;
    private static String projectRoot;

    public BallerinaPackageFieldCompletionProvider(@NotNull Producer<Module> moduleProducer) {
        myModuleProducer = moduleProducer;
    }

    @Override
    protected void addCompletionVariants(@NotNull String text, int offset, @NotNull String prefix,
                                         @NotNull CompletionResultSet result) {
        Module module = myModuleProducer.produce();
        if (module != null) {
            Project project = module.getProject();
            VirtualFile projectBaseDir = project.getBaseDir();
            projectRoot = projectBaseDir.getPath();
            addDirectories(result, projectBaseDir);
        }
    }

    private void addDirectories(CompletionResultSet result, VirtualFile directory) {
        VirtualFile[] children = directory.getChildren();
        for (VirtualFile child : children) {
            if (child.isDirectory()) {
                if (child.getName().startsWith(".")) {
                    continue;
                }
                String relativePath = child.getPath().replaceFirst(projectRoot + File.separator, "");
                result.addElement(LookupElementBuilder.create(relativePath));
                addDirectories(result, child);
            }
        }
    }
}
